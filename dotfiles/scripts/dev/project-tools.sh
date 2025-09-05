#!/bin/bash

# Project Management and Scaffolding Tools
# Part of the Portable Neovim IDE Dotfiles

# ============================================================================
# PROJECT TEMPLATES
# ============================================================================

# Project templates directory
TEMPLATES_DIR="$HOME/.config/project-templates"

# Initialize templates
init_templates() {
    mkdir -p "$TEMPLATES_DIR"
    
    # Create React template
    cat > "$TEMPLATES_DIR/react.json" << 'EOF'
{
  "name": "react",
  "description": "Modern React app with TypeScript, Vite, and TailwindCSS",
  "commands": [
    "npm create vite@latest . -- --template react-ts",
    "npm install",
    "npm install -D tailwindcss postcss autoprefixer @types/node",
    "npx tailwindcss init -p",
    "npm install react-router-dom axios react-query zustand",
    "npm install -D @testing-library/react @testing-library/jest-dom vitest",
    "npm install -D eslint prettier eslint-config-prettier eslint-plugin-react"
  ],
  "files": {
    ".prettierrc": {
      "semi": false,
      "singleQuote": true,
      "trailingComma": "es5"
    },
    ".eslintrc.json": {
      "extends": ["react-app", "prettier"],
      "rules": {}
    }
  }
}
EOF

    # Create Next.js template
    cat > "$TEMPLATES_DIR/nextjs.json" << 'EOF'
{
  "name": "nextjs",
  "description": "Next.js 14 app with TypeScript, Tailwind, and App Router",
  "commands": [
    "npx create-next-app@latest . --typescript --tailwind --app --eslint",
    "npm install axios react-query zustand",
    "npm install -D @types/node"
  ],
  "files": {
    ".env.local": "# Environment variables\nNEXT_PUBLIC_API_URL=http://localhost:3000"
  }
}
EOF

    # Create Node.js API template
    cat > "$TEMPLATES_DIR/node-api.json" << 'EOF'
{
  "name": "node-api",
  "description": "Node.js Express API with TypeScript and Prisma",
  "commands": [
    "npm init -y",
    "npm install express cors helmet morgan compression dotenv",
    "npm install -D typescript @types/node @types/express @types/cors",
    "npm install -D nodemon ts-node prisma @prisma/client",
    "npm install -D eslint prettier @typescript-eslint/parser @typescript-eslint/eslint-plugin",
    "npx tsc --init",
    "npx prisma init"
  ],
  "files": {
    "src/index.ts": "import express from 'express'\nconst app = express()\napp.listen(3000)",
    "nodemon.json": {
      "watch": ["src"],
      "ext": "ts",
      "exec": "ts-node src/index.ts"
    }
  }
}
EOF

    echo "Project templates initialized"
}

# Create new project from template
project_new() {
    local template="$1"
    local name="$2"
    
    if [ -z "$template" ] || [ -z "$name" ]; then
        echo "Usage: project_new <template> <project-name>"
        echo "Available templates:"
        ls -1 "$TEMPLATES_DIR" | sed 's/\.json$//'
        return 1
    fi
    
    local template_file="$TEMPLATES_DIR/${template}.json"
    
    if [ ! -f "$template_file" ]; then
        echo "Template '$template' not found"
        return 1
    fi
    
    echo "🚀 Creating $template project: $name"
    
    # Create project directory
    mkdir -p "$name"
    cd "$name" || return 1
    
    # Initialize git
    git init
    
    # Run template commands
    local commands=$(jq -r '.commands[]' "$template_file")
    while IFS= read -r cmd; do
        echo "Running: $cmd"
        eval "$cmd"
    done <<< "$commands"
    
    # Create template files
    jq -r '.files | to_entries[] | "\(.key)\n\(.value)"' "$template_file" | while IFS= read -r file && IFS= read -r content; do
        echo "Creating: $file"
        if [[ "$content" == "{"* ]]; then
            echo "$content" | jq '.' > "$file"
        else
            echo "$content" > "$file"
        fi
    done
    
    # Create standard directories
    mkdir -p src tests docs public
    
    # Create README
    cat > README.md << EOF
# $name

Created with $template template.

## Scripts

\`\`\`bash
npm run dev      # Start development server
npm run build    # Build for production
npm run test     # Run tests
npm run lint     # Run linter
\`\`\`

## Environment Variables

Copy \`.env.example\` to \`.env\` and update values.

## License

MIT
EOF
    
    # Create .gitignore
    cat > .gitignore << 'EOF'
node_modules/
dist/
build/
.env
.env.local
.DS_Store
*.log
coverage/
.vscode/
.idea/
EOF
    
    echo "✅ Project created successfully!"
    echo "Next steps:"
    echo "  cd $name"
    echo "  npm run dev"
}

# Project switcher with tmux integration
project_switch() {
    local project_dir="${1:-$HOME/dev}"
    
    # Find all git repositories
    local projects=$(find "$project_dir" -maxdepth 3 -type d -name ".git" 2>/dev/null | xargs -I {} dirname {} | sort)
    
    # Use fzf to select project
    local selected=$(echo "$projects" | fzf --preview 'ls -la {}' --preview-window=right:50%)
    
    if [ -n "$selected" ]; then
        local project_name=$(basename "$selected")
        
        # Create or switch tmux session
        if [ -n "$TMUX" ]; then
            tmux new-session -d -s "$project_name" -c "$selected" 2>/dev/null || true
            tmux switch-client -t "$project_name"
        else
            tmux new-session -A -s "$project_name" -c "$selected"
        fi
    fi
}

# Environment file management
env_edit() {
    local env_file="${1:-.env}"
    
    if [ ! -f "$env_file" ]; then
        echo "Creating $env_file from template..."
        if [ -f ".env.example" ]; then
            cp ".env.example" "$env_file"
        else
            touch "$env_file"
        fi
    fi
    
    # Edit with encryption awareness
    if command -v sops &> /dev/null && [ -f ".sops.yaml" ]; then
        sops "$env_file"
    else
        ${EDITOR:-nvim} "$env_file"
    fi
}

# Secret management
secret_add() {
    local key="$1"
    local value="$2"
    local env_file="${3:-.env}"
    
    if [ -z "$key" ] || [ -z "$value" ]; then
        echo "Usage: secret_add KEY VALUE [env-file]"
        return 1
    fi
    
    # Check if key already exists
    if grep -q "^$key=" "$env_file" 2>/dev/null; then
        echo "Key '$key' already exists. Use secret_update instead."
        return 1
    fi
    
    echo "$key=$value" >> "$env_file"
    echo "✅ Secret added to $env_file"
}

# Project dependency checker
project_deps() {
    echo "📦 Checking project dependencies..."
    
    # Node.js
    if [ -f "package.json" ]; then
        echo -e "\n📌 Node.js Dependencies:"
        if command -v npm-check &> /dev/null; then
            npm-check
        else
            npm outdated
        fi
    fi
    
    # Python
    if [ -f "requirements.txt" ] || [ -f "Pipfile" ]; then
        echo -e "\n🐍 Python Dependencies:"
        if [ -f "Pipfile" ]; then
            pipenv check
        else
            pip list --outdated
        fi
    fi
    
    # Ruby
    if [ -f "Gemfile" ]; then
        echo -e "\n💎 Ruby Dependencies:"
        bundle outdated
    fi
    
    # Security audit
    echo -e "\n🔒 Security Audit:"
    if [ -f "package.json" ]; then
        npm audit
    fi
}

# Project cleanup
project_clean() {
    echo "🧹 Cleaning project..."
    
    # Remove node_modules
    [ -d "node_modules" ] && rm -rf node_modules && echo "Removed node_modules"
    
    # Remove build artifacts
    [ -d "dist" ] && rm -rf dist && echo "Removed dist"
    [ -d "build" ] && rm -rf build && echo "Removed build"
    [ -d ".next" ] && rm -rf .next && echo "Removed .next"
    
    # Remove cache directories
    [ -d ".cache" ] && rm -rf .cache && echo "Removed .cache"
    [ -d "coverage" ] && rm -rf coverage && echo "Removed coverage"
    
    # Remove log files
    find . -name "*.log" -type f -delete 2>/dev/null && echo "Removed log files"
    
    # Remove DS_Store files (macOS)
    find . -name ".DS_Store" -type f -delete 2>/dev/null && echo "Removed .DS_Store files"
    
    echo "✅ Project cleaned"
}

# Git hooks setup
project_hooks() {
    echo "🪝 Setting up git hooks..."
    
    # Install husky if package.json exists
    if [ -f "package.json" ]; then
        npm install -D husky lint-staged
        npx husky install
        
        # Pre-commit hook
        npx husky add .husky/pre-commit "npx lint-staged"
        
        # Create lint-staged config
        cat > .lintstagedrc.json << 'EOF'
{
  "*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
  "*.{json,md,yml,yaml}": ["prettier --write"]
}
EOF
        
        echo "✅ Husky hooks configured"
    fi
    
    # Create commit message template
    cat > .gitmessage << 'EOF'
# <type>(<scope>): <subject>
#
# <body>
#
# <footer>
#
# Type: feat, fix, docs, style, refactor, test, chore
# Scope: component or file name
# Subject: what was done
# Body: why it was done
# Footer: breaking changes, issues closed
EOF
    
    git config commit.template .gitmessage
    echo "✅ Commit template configured"
}

# Initialize templates on first run
[ ! -d "$TEMPLATES_DIR" ] && init_templates

# Export functions
export -f project_new
export -f project_switch
export -f env_edit
export -f secret_add
export -f project_deps
export -f project_clean
export -f project_hooks