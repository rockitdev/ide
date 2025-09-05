#!/bin/bash

# Development Workflow Automation
# Part of the Portable Neovim IDE Dotfiles

# ============================================================================
# DEVELOPMENT WORKFLOWS
# ============================================================================

# Start development environment
dev_start() {
    local project="${1:-.}"
    
    echo "🚀 Starting development environment..."
    
    # Change to project directory
    cd "$project" || return 1
    
    # Detect project type and start appropriate services
    if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
        echo "Starting Docker services..."
        docker-compose up -d
    fi
    
    # Start database services if needed
    if [ -f "package.json" ] && grep -q "prisma\|typeorm\|sequelize" package.json; then
        echo "Checking database connection..."
        if ! nc -z localhost 5432 2>/dev/null && ! nc -z localhost 3306 2>/dev/null; then
            echo "Starting local database..."
            if command -v docker &> /dev/null; then
                docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres:latest
            fi
        fi
    fi
    
    # Install dependencies if needed
    if [ -f "package.json" ] && [ ! -d "node_modules" ]; then
        echo "Installing Node dependencies..."
        npm install
    fi
    
    if [ -f "requirements.txt" ] && [ ! -d "venv" ]; then
        echo "Creating Python virtual environment..."
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    fi
    
    # Run migrations
    if [ -f "package.json" ] && grep -q "migrate" package.json; then
        echo "Running database migrations..."
        npm run migrate 2>/dev/null || true
    fi
    
    # Start development server in tmux
    if [ -n "$TMUX" ]; then
        tmux split-window -h -p 30
        tmux send-keys "npm run dev" C-m
        tmux select-pane -L
    else
        # Create new tmux session for project
        local session_name=$(basename "$PWD")
        tmux new-session -d -s "$session_name"
        tmux send-keys -t "$session_name" "npm run dev" C-m
        tmux split-window -t "$session_name" -h
        tmux attach -t "$session_name"
    fi
    
    echo "✅ Development environment ready!"
}

# Stop development environment
dev_stop() {
    echo "🛑 Stopping development environment..."
    
    # Stop Docker services
    if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
        docker-compose down
    fi
    
    # Kill development servers
    lsof -ti:3000 | xargs kill -9 2>/dev/null
    lsof -ti:8080 | xargs kill -9 2>/dev/null
    lsof -ti:5173 | xargs kill -9 2>/dev/null  # Vite
    
    echo "✅ Development environment stopped"
}

# Run all tests
test_all() {
    echo "🧪 Running all tests..."
    
    # Node.js tests
    if [ -f "package.json" ]; then
        if grep -q "\"test\"" package.json; then
            echo "Running Node.js tests..."
            npm test
        fi
    fi
    
    # Python tests
    if [ -f "pytest.ini" ] || [ -d "tests" ]; then
        echo "Running Python tests..."
        if command -v pytest &> /dev/null; then
            pytest
        elif [ -f "manage.py" ]; then
            python manage.py test
        fi
    fi
    
    # Ruby tests
    if [ -f "Gemfile" ] && [ -d "spec" ]; then
        echo "Running Ruby tests..."
        bundle exec rspec
    fi
    
    echo "✅ All tests completed"
}

# Code quality checks
code_check() {
    echo "🔍 Running code quality checks..."
    
    # Linting
    if [ -f "package.json" ] && grep -q "\"lint\"" package.json; then
        echo "Running ESLint..."
        npm run lint
    fi
    
    if command -v flake8 &> /dev/null; then
        echo "Running Flake8..."
        flake8 . 2>/dev/null || true
    fi
    
    # Type checking
    if [ -f "tsconfig.json" ]; then
        echo "Running TypeScript check..."
        npx tsc --noEmit
    fi
    
    # Security audit
    if [ -f "package.json" ]; then
        echo "Running security audit..."
        npm audit
    fi
    
    echo "✅ Code quality checks completed"
}

# Build for production
build_prod() {
    echo "🏗️  Building for production..."
    
    # Clean previous builds
    rm -rf dist build .next out 2>/dev/null
    
    # Node.js build
    if [ -f "package.json" ] && grep -q "\"build\"" package.json; then
        npm run build
    fi
    
    # Python build
    if [ -f "setup.py" ]; then
        python setup.py sdist bdist_wheel
    fi
    
    # Docker build
    if [ -f "Dockerfile" ]; then
        echo "Building Docker image..."
        local image_name=$(basename "$PWD" | tr '[:upper:]' '[:lower:]')
        docker build -t "$image_name:latest" .
    fi
    
    echo "✅ Production build completed"
}

# Deploy to staging/production
deploy() {
    local environment="${1:-staging}"
    local branch="${2:-main}"
    
    echo "🚀 Deploying to $environment from $branch..."
    
    # Ensure we're on the right branch
    git checkout "$branch"
    git pull origin "$branch"
    
    # Run tests first
    test_all || { echo "❌ Tests failed, aborting deployment"; return 1; }
    
    # Build
    build_prod || { echo "❌ Build failed, aborting deployment"; return 1; }
    
    # Deploy based on platform detection
    if [ -f "vercel.json" ]; then
        echo "Deploying to Vercel..."
        vercel --prod
    elif [ -f "netlify.toml" ]; then
        echo "Deploying to Netlify..."
        netlify deploy --prod
    elif [ -f "app.yaml" ]; then
        echo "Deploying to Google App Engine..."
        gcloud app deploy
    elif [ -f "Procfile" ]; then
        echo "Deploying to Heroku..."
        git push heroku "$branch:main"
    elif [ -f ".github/workflows/deploy.yml" ]; then
        echo "Triggering GitHub Actions deployment..."
        gh workflow run deploy.yml
    else
        echo "⚠️  No deployment configuration found"
        echo "Supported platforms: Vercel, Netlify, Google App Engine, Heroku, GitHub Actions"
    fi
    
    echo "✅ Deployment completed"
}

# Generate release
release() {
    local version="${1:-patch}"
    
    echo "📦 Creating release..."
    
    # Ensure working directory is clean
    if [ -n "$(git status --porcelain)" ]; then
        echo "❌ Working directory is not clean. Commit or stash changes first."
        return 1
    fi
    
    # Update version
    if [ -f "package.json" ]; then
        echo "Updating version in package.json..."
        npm version "$version" --no-git-tag-version
        version=$(node -p "require('./package.json').version")
    fi
    
    # Generate changelog
    echo "Generating changelog..."
    git log --pretty=format:"- %s" "$(git describe --tags --abbrev=0)..HEAD" > CHANGELOG_TEMP.md
    
    if [ -f "CHANGELOG.md" ]; then
        echo -e "## v$version - $(date +%Y-%m-%d)\n" | cat - CHANGELOG_TEMP.md CHANGELOG.md > temp && mv temp CHANGELOG.md
    else
        echo -e "# Changelog\n\n## v$version - $(date +%Y-%m-%d)\n" | cat - CHANGELOG_TEMP.md > CHANGELOG.md
    fi
    rm CHANGELOG_TEMP.md
    
    # Commit and tag
    git add .
    git commit -m "chore: release v$version"
    git tag -a "v$version" -m "Release v$version"
    
    # Push
    git push origin main
    git push origin "v$version"
    
    # Create GitHub release if gh is installed
    if command -v gh &> /dev/null; then
        gh release create "v$version" --generate-notes
    fi
    
    echo "✅ Release v$version created"
}

# Hot reload development
dev_watch() {
    echo "👁️  Starting hot reload development..."
    
    # Node.js with nodemon
    if [ -f "package.json" ]; then
        if grep -q "nodemon" package.json; then
            npx nodemon
        elif grep -q "\"dev\"" package.json; then
            npm run dev
        else
            npx nodemon --exec "node" index.js
        fi
    fi
    
    # Python with watchdog
    if [ -f "requirements.txt" ] && command -v watchmedo &> /dev/null; then
        watchmedo auto-restart -d . -p '*.py' -- python app.py
    fi
}

# Database operations
db_reset() {
    echo "🗄️  Resetting database..."
    
    # Drop and recreate database
    if [ -f "package.json" ] && grep -q "prisma" package.json; then
        npx prisma migrate reset --force
    elif [ -f "knexfile.js" ]; then
        npx knex migrate:rollback --all
        npx knex migrate:latest
        npx knex seed:run
    elif [ -f "manage.py" ]; then
        python manage.py flush --noinput
        python manage.py migrate
        python manage.py loaddata fixtures/*.json 2>/dev/null || true
    fi
    
    echo "✅ Database reset completed"
}

# Quick commit with conventional commits
quick_commit() {
    local type="${1:-feat}"
    local message="$2"
    
    if [ -z "$message" ]; then
        echo "Usage: quick_commit [type] message"
        echo "Types: feat, fix, docs, style, refactor, test, chore"
        return 1
    fi
    
    git add -A
    git commit -m "$type: $message"
}

# PR creation helper
pr_create() {
    local title="${1:-$(git log -1 --pretty=%B)}"
    local body="${2:-}"
    
    echo "📝 Creating pull request..."
    
    # Push current branch
    local branch=$(git branch --show-current)
    git push -u origin "$branch"
    
    # Create PR
    if command -v gh &> /dev/null; then
        gh pr create --title "$title" --body "$body" --web
    else
        echo "Install GitHub CLI (gh) to create PRs from terminal"
        echo "Visit: https://github.com/$(git remote get-url origin | sed 's/.*://;s/\.git$//')/compare/$branch"
    fi
}

# Export all functions
export -f dev_start
export -f dev_stop
export -f test_all
export -f code_check
export -f build_prod
export -f deploy
export -f release
export -f dev_watch
export -f db_reset
export -f quick_commit
export -f pr_create