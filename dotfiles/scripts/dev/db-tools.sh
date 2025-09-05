#!/bin/bash

# Database Tools and Helpers
# Part of the Portable Neovim IDE Dotfiles

# ============================================================================
# DATABASE CONNECTION MANAGER
# ============================================================================

# Database connections configuration file
DB_CONFIG_FILE="$HOME/.config/db-connections.json"

# Initialize config file if it doesn't exist
init_db_config() {
    if [ ! -f "$DB_CONFIG_FILE" ]; then
        mkdir -p "$(dirname "$DB_CONFIG_FILE")"
        cat > "$DB_CONFIG_FILE" << 'EOF'
{
  "connections": {
    "local-postgres": {
      "type": "postgresql",
      "host": "localhost",
      "port": 5432,
      "database": "development",
      "user": "dev"
    },
    "local-mysql": {
      "type": "mysql",
      "host": "localhost",
      "port": 3306,
      "database": "development",
      "user": "root"
    },
    "local-redis": {
      "type": "redis",
      "host": "localhost",
      "port": 6379
    },
    "local-mongo": {
      "type": "mongodb",
      "host": "localhost",
      "port": 27017,
      "database": "development"
    }
  }
}
EOF
        echo "Database config initialized at $DB_CONFIG_FILE"
    fi
}

# Connect to database using saved profile
db_connect() {
    local profile="$1"
    
    if [ -z "$profile" ]; then
        echo "Available connections:"
        jq -r '.connections | keys[]' "$DB_CONFIG_FILE" 2>/dev/null
        return
    fi
    
    local conn=$(jq -r ".connections[\"$profile\"]" "$DB_CONFIG_FILE" 2>/dev/null)
    
    if [ "$conn" = "null" ]; then
        echo "Connection profile '$profile' not found"
        return 1
    fi
    
    local type=$(echo "$conn" | jq -r '.type')
    local host=$(echo "$conn" | jq -r '.host')
    local port=$(echo "$conn" | jq -r '.port')
    local database=$(echo "$conn" | jq -r '.database // empty')
    local user=$(echo "$conn" | jq -r '.user // empty')
    
    case "$type" in
        postgresql)
            psql -h "$host" -p "$port" -U "$user" "$database"
            ;;
        mysql)
            mysql -h "$host" -P "$port" -u "$user" "$database"
            ;;
        redis)
            redis-cli -h "$host" -p "$port"
            ;;
        mongodb)
            mongosh --host "$host" --port "$port" "$database"
            ;;
        *)
            echo "Unknown database type: $type"
            return 1
            ;;
    esac
}

# Quick database backup
db_backup() {
    local profile="$1"
    local output_dir="${2:-$HOME/backups}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    mkdir -p "$output_dir"
    
    local conn=$(jq -r ".connections[\"$profile\"]" "$DB_CONFIG_FILE" 2>/dev/null)
    
    if [ "$conn" = "null" ]; then
        echo "Connection profile '$profile' not found"
        return 1
    fi
    
    local type=$(echo "$conn" | jq -r '.type')
    local host=$(echo "$conn" | jq -r '.host')
    local port=$(echo "$conn" | jq -r '.port')
    local database=$(echo "$conn" | jq -r '.database // empty')
    local user=$(echo "$conn" | jq -r '.user // empty')
    
    case "$type" in
        postgresql)
            local backup_file="$output_dir/${database}_${timestamp}.sql"
            pg_dump -h "$host" -p "$port" -U "$user" "$database" > "$backup_file"
            echo "PostgreSQL backup saved to: $backup_file"
            ;;
        mysql)
            local backup_file="$output_dir/${database}_${timestamp}.sql"
            mysqldump -h "$host" -P "$port" -u "$user" "$database" > "$backup_file"
            echo "MySQL backup saved to: $backup_file"
            ;;
        mongodb)
            local backup_dir="$output_dir/mongo_${database}_${timestamp}"
            mongodump --host "$host" --port "$port" --db "$database" --out "$backup_dir"
            echo "MongoDB backup saved to: $backup_dir"
            ;;
        redis)
            echo "Redis backup: Use BGSAVE command in Redis CLI"
            ;;
        *)
            echo "Backup not supported for type: $type"
            return 1
            ;;
    esac
}

# Database migration helper
db_migrate() {
    local direction="${1:-up}"
    local framework="${2:-auto}"
    
    # Auto-detect framework
    if [ "$framework" = "auto" ]; then
        if [ -f "knexfile.js" ]; then
            framework="knex"
        elif [ -f "ormconfig.json" ] || [ -f "ormconfig.js" ]; then
            framework="typeorm"
        elif [ -f "prisma/schema.prisma" ]; then
            framework="prisma"
        elif [ -f "db/migrate" ]; then
            framework="rails"
        elif [ -f "migrations" ]; then
            framework="django"
        else
            echo "Could not auto-detect migration framework"
            return 1
        fi
    fi
    
    echo "Running $direction migration with $framework..."
    
    case "$framework" in
        knex)
            if [ "$direction" = "up" ]; then
                npx knex migrate:latest
            else
                npx knex migrate:rollback
            fi
            ;;
        typeorm)
            if [ "$direction" = "up" ]; then
                npx typeorm migration:run
            else
                npx typeorm migration:revert
            fi
            ;;
        prisma)
            if [ "$direction" = "up" ]; then
                npx prisma migrate deploy
            else
                echo "Prisma doesn't support rollback. Use: npx prisma migrate reset"
            fi
            ;;
        rails)
            if [ "$direction" = "up" ]; then
                rails db:migrate
            else
                rails db:rollback
            fi
            ;;
        django)
            if [ "$direction" = "up" ]; then
                python manage.py migrate
            else
                python manage.py migrate --backwards
            fi
            ;;
        *)
            echo "Unknown framework: $framework"
            return 1
            ;;
    esac
}

# Database seed helper
db_seed() {
    local framework="${1:-auto}"
    
    # Auto-detect framework
    if [ "$framework" = "auto" ]; then
        if [ -f "knexfile.js" ]; then
            framework="knex"
        elif [ -f "prisma/schema.prisma" ]; then
            framework="prisma"
        elif [ -f "db/seeds.rb" ]; then
            framework="rails"
        elif [ -f "manage.py" ]; then
            framework="django"
        else
            echo "Could not auto-detect framework"
            return 1
        fi
    fi
    
    echo "Seeding database with $framework..."
    
    case "$framework" in
        knex)
            npx knex seed:run
            ;;
        prisma)
            npx prisma db seed
            ;;
        rails)
            rails db:seed
            ;;
        django)
            python manage.py loaddata fixtures/*.json
            ;;
        *)
            echo "Unknown framework: $framework"
            return 1
            ;;
    esac
}

# SQL query helper with syntax highlighting
sql() {
    local query="$1"
    local profile="${2:-local-postgres}"
    
    if [ -z "$query" ]; then
        echo "Usage: sql 'SELECT * FROM users' [profile]"
        return 1
    fi
    
    echo "$query" | db_connect "$profile" | bat --language=sql
}

# Initialize on first run
init_db_config

# Export functions for use in shell
export -f db_connect
export -f db_backup
export -f db_migrate
export -f db_seed
export -f sql