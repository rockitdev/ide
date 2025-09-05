#!/bin/bash

# Monitoring and Debugging Tools
# Part of the Portable Neovim IDE Dotfiles

# ============================================================================
# LOG MONITORING
# ============================================================================

# Tail logs with syntax highlighting
logs() {
    local file="${1:-/var/log/system.log}"
    local lines="${2:-100}"
    
    if [ ! -f "$file" ] && [ -d "logs" ]; then
        # Try to find log files in logs directory
        file=$(find logs -name "*.log" -type f | head -1)
    fi
    
    if [ -f "$file" ]; then
        # Use bat for syntax highlighting if available
        if command -v bat &> /dev/null; then
            tail -f -n "$lines" "$file" | bat --paging=never --style=plain --language=log
        else
            tail -f -n "$lines" "$file"
        fi
    else
        echo "Log file not found: $file"
        echo "Available logs:"
        find . -name "*.log" -type f 2>/dev/null | head -10
    fi
}

# Multi-file log monitoring
multi_logs() {
    if command -v multitail &> /dev/null; then
        multitail "$@"
    else
        echo "Please install multitail for multi-file log monitoring"
        echo "Falling back to tail -f"
        tail -f "$@"
    fi
}

# Docker logs helper
docker_logs() {
    local container="${1:-$(docker ps --format 'table {{.Names}}' | sed 1d | fzf)}"
    
    if [ -n "$container" ]; then
        docker logs -f --tail=100 "$container" 2>&1 | bat --paging=never --style=plain --language=log
    fi
}

# ============================================================================
# PROCESS MONITORING
# ============================================================================

# Enhanced process viewer
proc() {
    if command -v btop &> /dev/null; then
        btop
    elif command -v htop &> /dev/null; then
        htop
    else
        top
    fi
}

# Port usage checker
ports() {
    local port="$1"
    
    if [ -n "$port" ]; then
        lsof -i ":$port" 2>/dev/null || netstat -an | grep ":$port"
    else
        echo "📡 Active ports:"
        if command -v lsof &> /dev/null; then
            lsof -i -P -n | grep LISTEN
        else
            netstat -tuln
        fi
    fi
}

# Process finder
find_proc() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo "Usage: find_proc <process-name>"
        return 1
    fi
    
    ps aux | grep -i "$name" | grep -v grep
}

# Memory usage by process
mem_usage() {
    ps aux | awk '{printf "%-20s %s\n", $11, $4}' | sort -k2 -rn | head -20
}

# CPU usage by process
cpu_usage() {
    ps aux | awk '{printf "%-20s %s\n", $11, $3}' | sort -k2 -rn | head -20
}

# ============================================================================
# NETWORK DEBUGGING
# ============================================================================

# Network monitoring
net_monitor() {
    if command -v nettop &> /dev/null; then
        sudo nettop
    elif command -v iftop &> /dev/null; then
        sudo iftop
    elif command -v nethogs &> /dev/null; then
        sudo nethogs
    else
        echo "Install nettop, iftop, or nethogs for network monitoring"
        netstat -i 1
    fi
}

# HTTP traffic debugging
http_debug() {
    local port="${1:-8888}"
    
    if command -v mitmproxy &> /dev/null; then
        echo "Starting mitmproxy on port $port"
        echo "Configure your app to use proxy: http://localhost:$port"
        mitmproxy --port "$port"
    elif command -v tcpdump &> /dev/null; then
        echo "Capturing HTTP traffic on port $port"
        sudo tcpdump -i any -s 0 -A "tcp port $port"
    else
        echo "Install mitmproxy or tcpdump for HTTP debugging"
    fi
}

# DNS lookup helper
dns_check() {
    local domain="$1"
    
    if [ -z "$domain" ]; then
        echo "Usage: dns_check <domain>"
        return 1
    fi
    
    echo "🔍 DNS information for $domain:"
    
    if command -v dog &> /dev/null; then
        dog "$domain"
    elif command -v dig &> /dev/null; then
        dig "$domain" +short
    else
        nslookup "$domain"
    fi
    
    echo -e "\n📍 Trace route:"
    if command -v mtr &> /dev/null; then
        mtr -r -c 1 "$domain"
    else
        traceroute "$domain"
    fi
}

# Connection testing
conn_test() {
    local host="${1:-google.com}"
    local port="${2:-443}"
    
    echo "🔌 Testing connection to $host:$port"
    
    if nc -zv "$host" "$port" 2>&1; then
        echo "✅ Connection successful"
        
        # Test SSL if HTTPS port
        if [ "$port" = "443" ]; then
            echo -e "\n🔒 SSL Certificate:"
            echo | openssl s_client -connect "$host:$port" 2>/dev/null | openssl x509 -noout -dates
        fi
    else
        echo "❌ Connection failed"
    fi
}

# ============================================================================
# PERFORMANCE PROFILING
# ============================================================================

# Node.js profiling
node_profile() {
    local script="${1:-index.js}"
    
    echo "📊 Profiling Node.js application..."
    
    if command -v clinic &> /dev/null; then
        clinic doctor -- node "$script"
    else
        node --prof "$script"
        echo "Profile data saved. Process with: node --prof-process isolate-*.log"
    fi
}

# Python profiling
python_profile() {
    local script="${1:-app.py}"
    
    echo "📊 Profiling Python application..."
    
    if command -v py-spy &> /dev/null; then
        py-spy record -o profile.svg -- python "$script"
    else
        python -m cProfile -o profile.stats "$script"
        echo "Profile data saved to profile.stats"
    fi
}

# Database query profiling
db_profile() {
    local query="$1"
    local db="${2:-postgresql}"
    
    case "$db" in
        postgresql|postgres)
            echo "EXPLAIN ANALYZE $query" | psql
            ;;
        mysql)
            echo "EXPLAIN $query" | mysql
            ;;
        *)
            echo "Unsupported database: $db"
            ;;
    esac
}

# ============================================================================
# ERROR TRACKING
# ============================================================================

# Error log aggregator
errors() {
    local since="${1:-1 hour ago}"
    
    echo "❌ Recent errors (since $since):"
    
    # Find all log files
    find . -name "*.log" -type f -newermt "$since" 2>/dev/null | while read -r file; do
        if grep -l -i "error\|exception\|fatal\|critical" "$file" > /dev/null; then
            echo -e "\n📁 $file:"
            grep -i "error\|exception\|fatal\|critical" "$file" | tail -5
        fi
    done
    
    # Check systemd journal if available
    if command -v journalctl &> /dev/null; then
        echo -e "\n📰 System errors:"
        journalctl --since "$since" -p err --no-pager | tail -10
    fi
}

# Stack trace formatter
stacktrace() {
    local file="${1:-}"
    
    if [ -n "$file" ] && [ -f "$file" ]; then
        # Format stack traces for better readability
        sed -E 's/^[[:space:]]+at/  📍/g' "$file" | \
        sed -E 's/\([^)]+:[0-9]+:[0-9]+\)/\x1b[33m&\x1b[0m/g'
    else
        echo "Usage: stacktrace <error-log-file>"
    fi
}

# ============================================================================
# SYSTEM HEALTH CHECK
# ============================================================================

# Overall system health
health_check() {
    echo "🏥 System Health Check"
    echo "====================="
    
    # CPU
    echo -e "\n💻 CPU:"
    uptime
    
    # Memory
    echo -e "\n🧠 Memory:"
    if command -v free &> /dev/null; then
        free -h
    else
        vm_stat
    fi
    
    # Disk
    echo -e "\n💾 Disk:"
    df -h | grep -v "tmpfs\|udev"
    
    # Network
    echo -e "\n🌐 Network:"
    ping -c 1 google.com &> /dev/null && echo "✅ Internet connected" || echo "❌ No internet"
    
    # Services
    echo -e "\n🚀 Services:"
    if command -v systemctl &> /dev/null; then
        systemctl --failed
    elif command -v launchctl &> /dev/null; then
        launchctl list | grep -E "^-|error"
    fi
    
    # Docker
    if command -v docker &> /dev/null; then
        echo -e "\n🐳 Docker:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    fi
}

# Resource monitor dashboard
monitor_dashboard() {
    # Create tmux session with monitoring tools
    tmux new-session -d -s monitor
    tmux send-keys -t monitor "btop" C-m
    tmux split-window -t monitor -h
    tmux send-keys -t monitor "docker stats" C-m
    tmux split-window -t monitor -v
    tmux send-keys -t monitor "tail -f *.log" C-m
    tmux attach -t monitor
}

# Export functions
export -f logs
export -f multi_logs
export -f docker_logs
export -f proc
export -f ports
export -f find_proc
export -f mem_usage
export -f cpu_usage
export -f net_monitor
export -f http_debug
export -f dns_check
export -f conn_test
export -f node_profile
export -f python_profile
export -f db_profile
export -f errors
export -f stacktrace
export -f health_check
export -f monitor_dashboard