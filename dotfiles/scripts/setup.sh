#!/bin/bash

# Dotfiles Setup Script
# This script sets up your development environment with all configurations

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load installation options if available
if [ -f "$(dirname "${BASH_SOURCE[0]}")/../.install_options" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../.install_options"
fi

# Set defaults if not provided
INSTALL_TERMINAL="${INSTALL_TERMINAL:-both}"
INSTALL_FONTS="${INSTALL_FONTS:-yes}"
INSTALL_NODEJS="${INSTALL_NODEJS:-yes}"
INSTALL_PYTHON="${INSTALL_PYTHON:-yes}"
INSTALL_RUST="${INSTALL_RUST:-no}"
CHANGE_SHELL="${CHANGE_SHELL:-yes}"

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Get the directory where the script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Detect OS (if not already detected by install.sh)
detect_os() {
    if [ -z "$OS" ]; then
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            OS="linux"
            if [ -f /etc/debian_version ]; then
                DISTRO="debian"
            elif [ -f /etc/redhat-release ]; then
                DISTRO="redhat"
            elif [ -f /etc/arch-release ]; then
                DISTRO="arch"
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            OS="macos"
        else
            print_error "Unsupported OS: $OSTYPE"
            exit 1
        fi
    fi
    print_info "Detected OS: $OS ${DISTRO:-}"
}

# Install Homebrew (macOS)
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        print_success "Homebrew installed"
    else
        print_info "Homebrew already installed"
    fi
}

# Install packages based on OS
install_packages() {
    print_info "Installing required packages..."
    
    if [[ "$OS" == "macos" ]]; then
        install_homebrew
        # Core packages
        brew install neovim tmux git ripgrep fzf fd bat eza zsh
        
        # Optional packages based on user selection
        if [ "$INSTALL_NODEJS" = "yes" ]; then
            brew install node
        fi
        if [ "$INSTALL_PYTHON" = "yes" ]; then
            brew install python3
        fi
        if [ "$INSTALL_RUST" = "yes" ]; then
            brew install rust
        fi
        
        # Terminal emulators based on selection
        if [ "$INSTALL_TERMINAL" = "alacritty" ] || [ "$INSTALL_TERMINAL" = "both" ]; then
            brew install --cask alacritty
        fi
        if [ "$INSTALL_TERMINAL" = "wezterm" ] || [ "$INSTALL_TERMINAL" = "both" ]; then
            brew install --cask wezterm
        fi
        
        # Fonts
        if [ "$INSTALL_FONTS" = "yes" ]; then
            brew install --cask font-jetbrains-mono-nerd-font
        fi
    elif [[ "$OS" == "linux" ]]; then
        case "$DISTRO" in
            debian)
                sudo apt update
                sudo apt install -y neovim tmux git ripgrep fzf fd-find bat zsh curl wget build-essential python3 python3-pip nodejs npm
                ;;
            arch)
                sudo pacman -Syu --noconfirm neovim tmux git ripgrep fzf fd bat exa zsh curl wget base-devel python python-pip nodejs npm
                ;;
            redhat)
                sudo dnf install -y neovim tmux git ripgrep fzf fd-find bat zsh curl wget gcc gcc-c++ make python3 python3-pip nodejs npm
                ;;
        esac
        
        # Install Rust on Linux
        if ! command -v cargo &> /dev/null; then
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
        fi
        
        # Install terminal emulators on Linux
        if [[ "$DISTRO" == "debian" ]]; then
            # Alacritty from cargo
            cargo install alacritty
        fi
    fi
    
    print_success "Packages installed"
}

# Install Nerd Fonts
install_fonts() {
    if [ "$INSTALL_FONTS" != "yes" ]; then
        print_info "Skipping font installation"
        return
    fi
    
    print_info "Installing Nerd Fonts..."
    
    if [[ "$OS" == "macos" ]]; then
        brew tap homebrew/cask-fonts 2>/dev/null || true
        brew install --cask font-hack-nerd-font font-fira-code-nerd-font 2>/dev/null || true
    else
        # Linux font installation
        mkdir -p ~/.local/share/fonts
        cd /tmp
        
        # Download JetBrainsMono Nerd Font
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
        unzip -q JetBrainsMono.zip -d JetBrainsMono
        cp JetBrainsMono/*.ttf ~/.local/share/fonts/
        rm -rf JetBrainsMono JetBrainsMono.zip
        
        # Update font cache
        fc-cache -fv ~/.local/share/fonts
    fi
    
    print_success "Fonts installed"
}

# Create symbolic links
create_symlinks() {
    print_info "Creating symbolic links..."
    
    # Create config directories if they don't exist
    mkdir -p "$HOME/.config"
    
    # Neovim
    if [ -e "$HOME/.config/nvim" ] || [ -L "$HOME/.config/nvim" ]; then
        print_warning "~/.config/nvim already exists. Backing up..."
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    print_success "Linked Neovim config"
    
    # Alacritty
    if [ -e "$HOME/.config/alacritty" ] || [ -L "$HOME/.config/alacritty" ]; then
        print_warning "~/.config/alacritty already exists. Backing up..."
        mv "$HOME/.config/alacritty" "$HOME/.config/alacritty.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    ln -sf "$DOTFILES_DIR/alacritty" "$HOME/.config/alacritty"
    print_success "Linked Alacritty config"
    
    # WezTerm
    if [ -e "$HOME/.config/wezterm" ] || [ -L "$HOME/.config/wezterm" ]; then
        print_warning "~/.config/wezterm already exists. Backing up..."
        mv "$HOME/.config/wezterm" "$HOME/.config/wezterm.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    ln -sf "$DOTFILES_DIR/wezterm" "$HOME/.config/wezterm"
    print_success "Linked WezTerm config"
    
    # Zsh
    if [ -e "$HOME/.zshrc" ] || [ -L "$HOME/.zshrc" ]; then
        print_warning "~/.zshrc already exists. Backing up..."
        mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    print_success "Linked Zsh config"
}

# Install Zinit (Zsh plugin manager)
install_zinit() {
    if [[ ! -d "${HOME}/.local/share/zinit/zinit.git" ]]; then
        print_info "Installing Zinit..."
        mkdir -p "${HOME}/.local/share/zinit"
        git clone https://github.com/zdharma-continuum/zinit.git "${HOME}/.local/share/zinit/zinit.git"
        print_success "Zinit installed"
    else
        print_info "Zinit already installed"
    fi
}

# Install Node.js packages
install_node_packages() {
    if [ "$INSTALL_NODEJS" != "yes" ]; then
        print_info "Skipping Node.js packages"
        return
    fi
    
    print_info "Installing Node.js packages..."
    
    if command -v npm &> /dev/null; then
        npm install -g neovim typescript typescript-language-server prettier eslint
        print_success "Node.js packages installed"
    else
        print_warning "npm not found. Skipping Node.js packages installation"
    fi
}

# Install Python packages
install_python_packages() {
    if [ "$INSTALL_PYTHON" != "yes" ]; then
        print_info "Skipping Python packages"
        return
    fi
    
    print_info "Installing Python packages..."
    
    if command -v pip3 &> /dev/null; then
        pip3 install --user pynvim black isort flake8 pylint
        print_success "Python packages installed"
    else
        print_warning "pip3 not found. Skipping Python packages installation"
    fi
}

# Install Claude CLI
install_claude_cli() {
    print_info "Installing Claude CLI..."
    
    if command -v npm &> /dev/null; then
        # Check if claude-code is available
        if npm view claude-code &> /dev/null; then
            npm install -g claude-code
            print_success "Claude CLI installed"
        else
            print_warning "claude-code package not found. You may need to install a different Claude CLI tool"
        fi
    else
        print_warning "npm not found. Skipping Claude CLI installation"
    fi
    
    print_info "Remember to set your ANTHROPIC_API_KEY environment variable in ~/.zshrc"
}

# Setup Neovim
setup_neovim() {
    print_info "Setting up Neovim..."
    
    # Install plugins
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    
    print_success "Neovim setup complete"
}

# Change default shell to Zsh
change_shell() {
    if [ "$CHANGE_SHELL" != "yes" ]; then
        print_info "Skipping shell change"
        return
    fi
    
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_info "Changing default shell to Zsh..."
        if command -v chsh &> /dev/null; then
            chsh -s "$(which zsh)"
            print_success "Default shell changed to Zsh. Please log out and log back in for the change to take effect."
        fi
    else
        print_info "Zsh is already the default shell"
    fi
}

# Main installation flow
main() {
    print_info "Starting dotfiles setup..."
    echo ""
    
    detect_os
    install_packages
    install_fonts
    create_symlinks
    install_zinit
    install_node_packages
    install_python_packages
    install_claude_cli
    setup_neovim
    change_shell
    
    echo ""
    print_success "🎉 Setup complete! 🎉"
    echo ""
    print_info "Next steps:"
    echo "  1. Set your ANTHROPIC_API_KEY in ~/.zshrc"
    echo "  2. Restart your terminal or run: source ~/.zshrc"
    echo "  3. Launch Neovim and wait for plugins to install"
    echo "  4. Enjoy your new development environment!"
    echo ""
    print_info "For Claude AI integration in Neovim:"
    echo "  - Use <leader>cc to open Claude chat"
    echo "  - Use <leader>ca for Claude actions"
    echo "  - Use <leader>tc to open Claude in a terminal"
}

# Run main function
main "$@"