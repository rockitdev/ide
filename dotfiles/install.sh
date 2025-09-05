#!/bin/bash

# One-Command Dotfiles Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/yourusername/dotfiles/main/install.sh | bash
# Or: wget -qO- https://raw.githubusercontent.com/yourusername/dotfiles/main/install.sh | bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration variables
GITHUB_USERNAME="${GITHUB_USERNAME:-rockitdev}"
REPO_NAME="${REPO_NAME:-ide}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/ide}"
INSTALL_DIR="${INSTALL_DIR:-$HOME}"

# ASCII Art Banner
print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
    ╔════════════════════════════════════════════════════╗
    ║                                                    ║
    ║     🚀 PORTABLE NEOVIM IDE INSTALLER 🚀           ║
    ║                                                    ║
    ║     Transparent • Fast • AI-Powered               ║
    ║                                                    ║
    ╚════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_question() {
    echo -e "${MAGENTA}[?]${NC} $1"
}

# Spinner animation
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='⣾⣽⣻⢿⡿⣟⣯⣷'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS and Distribution
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
            DISTRO_VERSION=$VERSION_ID
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
        DISTRO_VERSION=$(sw_vers -productVersion)
    else
        print_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

# Get user input with default value
get_input() {
    local prompt="$1"
    local default="$2"
    local input
    
    if [ -n "$default" ]; then
        read -p "$(echo -e ${MAGENTA}[?]${NC} $prompt [$default]: )" input
        echo "${input:-$default}"
    else
        read -p "$(echo -e ${MAGENTA}[?]${NC} $prompt: )" input
        echo "$input"
    fi
}

# Get yes/no input
get_confirmation() {
    local prompt="$1"
    local default="${2:-y}"
    local input
    
    if [ "$default" = "y" ]; then
        read -p "$(echo -e ${MAGENTA}[?]${NC} $prompt [Y/n]: )" input
        input="${input:-y}"
    else
        read -p "$(echo -e ${MAGENTA}[?]${NC} $prompt [y/N]: )" input
        input="${input:-n}"
    fi
    
    [[ "$input" =~ ^[Yy]$ ]]
}

# Get password input (hidden)
get_password() {
    local prompt="$1"
    local password
    echo -ne "${MAGENTA}[?]${NC} $prompt: "
    read -s password
    echo
    echo "$password"
}

# Check internet connection
check_internet() {
    print_info "Checking internet connection..."
    if ping -c 1 google.com &> /dev/null || ping -c 1 github.com &> /dev/null; then
        print_success "Internet connection verified"
        return 0
    else
        print_error "No internet connection detected"
        return 1
    fi
}

# Install prerequisites based on OS
install_prerequisites() {
    print_info "Installing prerequisites..."
    
    if [[ "$OS" == "macos" ]]; then
        # Install Xcode Command Line Tools if needed
        if ! xcode-select -p &> /dev/null; then
            print_info "Installing Xcode Command Line Tools..."
            xcode-select --install &> /dev/null
            print_warning "Please complete the Xcode Command Line Tools installation and run this script again"
            exit 1
        fi
        
        # Install Homebrew if needed
        if ! command_exists brew; then
            print_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null
            
            # Add Homebrew to PATH for Apple Silicon Macs
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
        fi
        
        # Install git if needed
        if ! command_exists git; then
            brew install git &> /dev/null &
            spinner
        fi
        
    elif [[ "$OS" == "linux" ]]; then
        # Install git and curl based on distribution
        if ! command_exists git || ! command_exists curl; then
            case "$DISTRO" in
                ubuntu|debian)
                    sudo apt-get update -qq
                    sudo apt-get install -y git curl wget &> /dev/null &
                    spinner
                    ;;
                fedora|rhel|centos)
                    sudo dnf install -y git curl wget &> /dev/null &
                    spinner
                    ;;
                arch|manjaro)
                    sudo pacman -Sy --noconfirm git curl wget &> /dev/null &
                    spinner
                    ;;
                *)
                    print_error "Unsupported Linux distribution: $DISTRO"
                    print_info "Please install git and curl manually"
                    exit 1
                    ;;
            esac
        fi
    fi
    
    print_success "Prerequisites installed"
}

# Clone or update dotfiles repository
setup_dotfiles() {
    print_info "Setting up dotfiles repository..."
    
    # Check if dotfiles already exist
    if [ -d "$DOTFILES_DIR" ]; then
        print_warning "Dotfiles directory already exists at $DOTFILES_DIR"
        if get_confirmation "Do you want to backup and replace it?"; then
            local backup_dir="${DOTFILES_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$DOTFILES_DIR" "$backup_dir"
            print_success "Existing dotfiles backed up to $backup_dir"
        else
            print_info "Using existing dotfiles directory"
            cd "$DOTFILES_DIR"
            git pull origin main &> /dev/null &
            spinner
            return
        fi
    fi
    
    # Clone repository
    print_info "Cloning dotfiles repository..."
    git clone "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git" "$DOTFILES_DIR" &> /dev/null &
    spinner
    
    cd "$DOTFILES_DIR"
    print_success "Dotfiles repository set up at $DOTFILES_DIR"
}

# Configure git settings
configure_git() {
    if get_confirmation "Do you want to configure Git settings?"; then
        local git_name=$(get_input "Enter your Git name" "$(git config --global user.name 2>/dev/null)")
        local git_email=$(get_input "Enter your Git email" "$(git config --global user.email 2>/dev/null)")
        
        if [ -n "$git_name" ]; then
            git config --global user.name "$git_name"
        fi
        
        if [ -n "$git_email" ]; then
            git config --global user.email "$git_email"
        fi
        
        print_success "Git configured"
    fi
}

# Configure API keys
configure_api_keys() {
    echo
    print_info "API Key Configuration"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Claude API Key
    if get_confirmation "Do you have an Anthropic/Claude API key?"; then
        print_info "Your API key will be stored in ~/.zshrc.local (not tracked by git)"
        local api_key=$(get_password "Enter your ANTHROPIC_API_KEY")
        if [ -n "$api_key" ]; then
            # Create .zshrc.local if it doesn't exist
            touch "$HOME/.zshrc.local"
            # Add to .zshrc.local (not tracked by git)
            echo "export ANTHROPIC_API_KEY=\"$api_key\"" >> "$HOME/.zshrc.local"
            print_success "Claude API key configured securely in ~/.zshrc.local"
        fi
    else
        print_info "You can get an API key from https://console.anthropic.com/"
        print_warning "Add it later to ~/.zshrc.local as: export ANTHROPIC_API_KEY=\"your-key\""
        print_info "Never commit API keys to version control!"
    fi
    
    # GitHub Token (optional)
    if get_confirmation "Do you have a GitHub personal access token? (for Octo.nvim)"; then
        local gh_token=$(get_password "Enter your GITHUB_TOKEN")
        if [ -n "$gh_token" ]; then
            echo "export GITHUB_TOKEN=\"$gh_token\"" >> "$HOME/.zshrc.local"
            print_success "GitHub token configured"
        fi
    fi
}

# Select terminal emulator
select_terminal() {
    echo
    print_info "Terminal Emulator Selection"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "1) Alacritty (GPU-accelerated, minimal)"
    echo "2) WezTerm (Feature-rich, Lua config)"
    echo "3) Both"
    echo "4) Skip terminal installation"
    
    local choice=$(get_input "Select terminal emulator [1-4]" "3")
    
    case $choice in
        1) INSTALL_TERMINAL="alacritty" ;;
        2) INSTALL_TERMINAL="wezterm" ;;
        3) INSTALL_TERMINAL="both" ;;
        4) INSTALL_TERMINAL="none" ;;
        *) INSTALL_TERMINAL="both" ;;
    esac
    
    print_success "Terminal selection: $INSTALL_TERMINAL"
}

# Select additional features
select_features() {
    echo
    print_info "Additional Features"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    INSTALL_FONTS=$(get_confirmation "Install Nerd Fonts?" "y" && echo "yes" || echo "no")
    INSTALL_NODEJS=$(get_confirmation "Install Node.js packages for LSP?" "y" && echo "yes" || echo "no")
    INSTALL_PYTHON=$(get_confirmation "Install Python packages for development?" "y" && echo "yes" || echo "no")
    INSTALL_RUST=$(get_confirmation "Install Rust toolchain?" "n" && echo "yes" || echo "no")
    CHANGE_SHELL=$(get_confirmation "Change default shell to Zsh?" "y" && echo "yes" || echo "no")
}

# Main installation
run_installation() {
    echo
    print_info "Starting installation..."
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Create a temporary file to store installation options
    cat > "$DOTFILES_DIR/.install_options" << EOF
export INSTALL_TERMINAL="$INSTALL_TERMINAL"
export INSTALL_FONTS="$INSTALL_FONTS"
export INSTALL_NODEJS="$INSTALL_NODEJS"
export INSTALL_PYTHON="$INSTALL_PYTHON"
export INSTALL_RUST="$INSTALL_RUST"
export CHANGE_SHELL="$CHANGE_SHELL"
export OS="$OS"
export DISTRO="$DISTRO"
EOF
    
    # Run the main setup script
    if [ -f "$DOTFILES_DIR/dotfiles/scripts/setup.sh" ]; then
        bash "$DOTFILES_DIR/dotfiles/scripts/setup.sh"
    else
        print_error "Setup script not found at $DOTFILES_DIR/dotfiles/scripts/setup.sh"
        exit 1
    fi
    
    # Clean up
    rm -f "$DOTFILES_DIR/.install_options"
}

# Post-installation message
post_install_message() {
    echo
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}     🎉 Installation Complete! 🎉${NC}"
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  ${BOLD}1.${NC} Restart your terminal or run: ${CYAN}source ~/.zshrc${NC}"
    echo -e "  ${BOLD}2.${NC} Launch Neovim: ${CYAN}nvim${NC}"
    echo -e "  ${BOLD}3.${NC} Wait for plugins to install automatically"
    echo
    echo -e "${CYAN}Quick commands:${NC}"
    echo -e "  ${BOLD}nvim${NC}          - Launch Neovim"
    echo -e "  ${BOLD}<leader>cc${NC}    - Open Claude chat (in Neovim)"
    echo -e "  ${BOLD}<leader>e${NC}     - File explorer (in Neovim)"
    echo -e "  ${BOLD}<leader>ff${NC}    - Find files (in Neovim)"
    echo -e "  ${BOLD}claude${NC}        - Launch Claude CLI (in terminal)"
    echo
    
    if [ "$INSTALL_TERMINAL" != "none" ]; then
        echo -e "${CYAN}Terminal:${NC}"
        if [[ "$INSTALL_TERMINAL" == "alacritty" ]] || [[ "$INSTALL_TERMINAL" == "both" ]]; then
            echo -e "  Launch Alacritty to experience transparency!"
        fi
        if [[ "$INSTALL_TERMINAL" == "wezterm" ]] || [[ "$INSTALL_TERMINAL" == "both" ]]; then
            echo -e "  Launch WezTerm for advanced features!"
        fi
        echo
    fi
    
    echo -e "${GREEN}Enjoy your new development environment!${NC}"
    echo -e "${YELLOW}Star the repo if you like it: https://github.com/rockitdev/ide${NC}"
    echo
}

# Error handler
handle_error() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo
        print_error "Installation failed with exit code $exit_code"
        print_info "Please check the error messages above"
        print_info "You can report issues at: https://github.com/rockitdev/ide/issues"
        exit $exit_code
    fi
}

# Trap errors
trap handle_error ERR

# Main execution flow
main() {
    clear
    print_banner
    
    # Initial setup
    detect_os
    print_success "Detected: $OS ${DISTRO:-} ${DISTRO_VERSION:-}"
    echo
    
    # Check if running from curl/wget or locally
    if [ -t 0 ]; then
        # Interactive mode
        print_info "Running in interactive mode"
        echo
        
        # Get GitHub username if not set
        if [ "$GITHUB_USERNAME" = "yourusername" ]; then
            GITHUB_USERNAME=$(get_input "Enter your GitHub username (or press Enter to use defaults)" "rockitdev")
        fi
        
        # Get repository name
        REPO_NAME=$(get_input "Enter repository name" "$REPO_NAME")
        
        # Get installation directory
        DOTFILES_DIR=$(get_input "Enter installation directory" "$DOTFILES_DIR")
    else
        # Non-interactive mode (piped from curl/wget)
        print_info "Running in automated mode"
        print_warning "Using default settings. Set environment variables for customization."
    fi
    
    echo
    
    # Pre-flight checks
    check_internet
    install_prerequisites
    
    # Main installation
    setup_dotfiles
    
    # Interactive configuration
    if [ -t 0 ]; then
        configure_git
        select_terminal
        select_features
        configure_api_keys
    else
        # Use defaults for non-interactive mode
        INSTALL_TERMINAL="both"
        INSTALL_FONTS="yes"
        INSTALL_NODEJS="yes"
        INSTALL_PYTHON="yes"
        INSTALL_RUST="no"
        CHANGE_SHELL="yes"
    fi
    
    # Run installation
    run_installation
    
    # Show completion message
    post_install_message
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi