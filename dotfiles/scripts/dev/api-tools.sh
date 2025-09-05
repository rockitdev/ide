#!/bin/bash

# API Development and Testing Tools
# Part of the Portable Neovim IDE Dotfiles

# ============================================================================
# API REQUEST HELPERS
# ============================================================================

# API endpoints configuration
API_CONFIG_FILE="$HOME/.config/api-endpoints.json"

# Initialize API config
init_api_config() {
    if [ ! -f "$API_CONFIG_FILE" ]; then
        mkdir -p "$(dirname "$API_CONFIG_FILE")"
        cat > "$API_CONFIG_FILE" << 'EOF'
{
  "environments": {
    "local": {
      "base_url": "http://localhost:3000",
      "headers": {
        "Content-Type": "application/json"
      }
    },
    "dev": {
      "base_url": "https://api-dev.example.com",
      "headers": {
        "Content-Type": "application/json"
      }
    },
    "staging": {
      "base_url": "https://api-staging.example.com",
      "headers": {
        "Content-Type": "application/json"
      }
    },
    "production": {
      "base_url": "https://api.example.com",
      "headers": {
        "Content-Type": "application/json"
      }
    }
  },
  "saved_requests": {
    "get_users": {
      "method": "GET",
      "endpoint": "/api/users"
    },
    "create_user": {
      "method": "POST",
      "endpoint": "/api/users",
      "body": {
        "name": "Test User",
        "email": "test@example.com"
      }
    }
  }
}
EOF
        echo "API config initialized at $API_CONFIG_FILE"
    fi
}

# Make API request using HTTPie
api() {
    local method="${1:-GET}"
    local endpoint="$2"
    local env="${3:-local}"
    local data="$4"
    
    if [ -z "$endpoint" ]; then
        echo "Usage: api [METHOD] endpoint [environment] [data]"
        echo "Example: api GET /users local"
        echo "Example: api POST /users local '{\"name\":\"John\"}'"
        return 1
    fi
    
    local base_url=$(jq -r ".environments[\"$env\"].base_url" "$API_CONFIG_FILE")
    
    if [ "$base_url" = "null" ]; then
        echo "Environment '$env' not found"
        return 1
    fi
    
    local full_url="${base_url}${endpoint}"
    
    echo "🚀 $method $full_url"
    
    if command -v http &> /dev/null; then
        if [ -n "$data" ]; then
            echo "$data" | http "$method" "$full_url" Content-Type:application/json
        else
            http "$method" "$full_url"
        fi
    elif command -v curl &> /dev/null; then
        if [ -n "$data" ]; then
            curl -X "$method" "$full_url" -H "Content-Type: application/json" -d "$data" | jq
        else
            curl -X "$method" "$full_url" -H "Content-Type: application/json" | jq
        fi
    else
        echo "Please install httpie or curl"
        return 1
    fi
}

# GraphQL query helper
graphql() {
    local query="$1"
    local env="${2:-local}"
    local endpoint="${3:-/graphql}"
    
    if [ -z "$query" ]; then
        echo "Usage: graphql 'query { users { id name } }' [environment] [endpoint]"
        return 1
    fi
    
    local base_url=$(jq -r ".environments[\"$env\"].base_url" "$API_CONFIG_FILE")
    
    if [ "$base_url" = "null" ]; then
        echo "Environment '$env' not found"
        return 1
    fi
    
    local full_url="${base_url}${endpoint}"
    local json_query=$(jq -n --arg q "$query" '{query: $q}')
    
    echo "🚀 GraphQL Query to $full_url"
    
    if command -v http &> /dev/null; then
        echo "$json_query" | http POST "$full_url" Content-Type:application/json
    else
        curl -X POST "$full_url" \
            -H "Content-Type: application/json" \
            -d "$json_query" | jq
    fi
}

# JWT decoder
jwt_decode() {
    local token="$1"
    
    if [ -z "$token" ]; then
        echo "Usage: jwt_decode 'your.jwt.token'"
        return 1
    fi
    
    # Remove Bearer prefix if present
    token="${token#Bearer }"
    
    # Split token into parts
    local header=$(echo "$token" | cut -d. -f1)
    local payload=$(echo "$token" | cut -d. -f2)
    
    echo "📋 JWT Header:"
    echo "$header" | base64 -d 2>/dev/null | jq
    
    echo -e "\n📦 JWT Payload:"
    echo "$payload" | base64 -d 2>/dev/null | jq
}

# WebSocket client
ws_connect() {
    local url="$1"
    
    if [ -z "$url" ]; then
        echo "Usage: ws_connect 'ws://localhost:3000/socket'"
        return 1
    fi
    
    if command -v websocat &> /dev/null; then
        websocat "$url"
    elif command -v wscat &> /dev/null; then
        wscat -c "$url"
    else
        echo "Please install websocat or wscat (npm install -g wscat)"
        return 1
    fi
}

# API response time testing
api_bench() {
    local endpoint="$1"
    local env="${2:-local}"
    local requests="${3:-100}"
    local concurrency="${4:-10}"
    
    if [ -z "$endpoint" ]; then
        echo "Usage: api_bench endpoint [environment] [requests] [concurrency]"
        return 1
    fi
    
    local base_url=$(jq -r ".environments[\"$env\"].base_url" "$API_CONFIG_FILE")
    
    if [ "$base_url" = "null" ]; then
        echo "Environment '$env' not found"
        return 1
    fi
    
    local full_url="${base_url}${endpoint}"
    
    echo "🏃 Benchmarking $full_url"
    echo "Requests: $requests, Concurrency: $concurrency"
    
    if command -v ab &> /dev/null; then
        ab -n "$requests" -c "$concurrency" "$full_url"
    elif command -v hey &> /dev/null; then
        hey -n "$requests" -c "$concurrency" "$full_url"
    else
        echo "Please install Apache Bench (ab) or hey"
        return 1
    fi
}

# Mock server launcher
mock_server() {
    local port="${1:-3001}"
    local spec_file="${2:-api-spec.json}"
    
    if [ -f "$spec_file" ]; then
        if command -v json-server &> /dev/null; then
            echo "🎭 Starting mock server on port $port"
            json-server --watch "$spec_file" --port "$port"
        else
            echo "Please install json-server: npm install -g json-server"
            return 1
        fi
    else
        echo "Creating sample mock data..."
        cat > "$spec_file" << 'EOF'
{
  "users": [
    { "id": 1, "name": "John Doe", "email": "john@example.com" },
    { "id": 2, "name": "Jane Smith", "email": "jane@example.com" }
  ],
  "posts": [
    { "id": 1, "title": "Hello World", "userId": 1 },
    { "id": 2, "title": "Another Post", "userId": 2 }
  ]
}
EOF
        echo "Mock data created in $spec_file"
        mock_server "$port" "$spec_file"
    fi
}

# API documentation generator
api_docs() {
    local spec_file="${1:-openapi.yaml}"
    local port="${2:-8080}"
    
    if [ -f "$spec_file" ]; then
        if command -v swagger-ui &> /dev/null; then
            swagger-ui serve "$spec_file" --port "$port"
        elif command -v redoc-cli &> /dev/null; then
            redoc-cli serve "$spec_file" --port "$port"
        else
            echo "Starting simple HTTP server for API docs..."
            python3 -m http.server "$port"
        fi
    else
        echo "API specification file not found: $spec_file"
        return 1
    fi
}

# Request/Response logger
api_log() {
    local enable="${1:-on}"
    
    if [ "$enable" = "on" ]; then
        export HTTP_LOG=1
        export CURL_TRACE=1
        echo "API logging enabled"
    else
        unset HTTP_LOG
        unset CURL_TRACE
        echo "API logging disabled"
    fi
}

# Initialize on first run
init_api_config

# Export functions
export -f api
export -f graphql
export -f jwt_decode
export -f ws_connect
export -f api_bench
export -f mock_server
export -f api_docs
export -f api_log