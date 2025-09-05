#!/bin/bash

# iTerm2 Setup Script
# This script installs and configures iTerm2 on macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is only for macOS"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Install iTerm2 if not already installed
install_iterm2() {
    if [ ! -d "/Applications/iTerm.app" ]; then
        print_info "Installing iTerm2..."
        if command -v brew &> /dev/null; then
            brew install --cask iterm2
            print_success "iTerm2 installed"
        else
            print_error "Homebrew not found. Please install Homebrew first"
            exit 1
        fi
    else
        print_info "iTerm2 is already installed"
    fi
}

# Import iTerm2 profile
import_iterm_profile() {
    print_info "Importing iTerm2 profile..."
    
    # Path to iTerm2 preferences
    ITERM_PREFS_DIR="$HOME/Library/Preferences"
    ITERM_PREFS_FILE="com.googlecode.iterm2.plist"
    
    # Backup existing preferences if they exist
    if [ -f "$ITERM_PREFS_DIR/$ITERM_PREFS_FILE" ]; then
        print_warning "Backing up existing iTerm2 preferences..."
        cp "$ITERM_PREFS_DIR/$ITERM_PREFS_FILE" "$ITERM_PREFS_DIR/$ITERM_PREFS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Copy our custom iTerm2 configuration
    cp "$DOTFILES_DIR/iterm2/$ITERM_PREFS_FILE" "$ITERM_PREFS_DIR/"
    print_success "iTerm2 profile imported"
    
    # Tell iTerm2 to reload preferences
    defaults read com.googlecode.iterm2 &> /dev/null
    
    print_info "You may need to restart iTerm2 for changes to take effect"
}

# Configure iTerm2 to use custom preferences directory
configure_custom_prefs() {
    print_info "Configuring iTerm2 to use custom preferences..."
    
    # Set iTerm2 to load preferences from a custom folder
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/iterm2"
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    
    print_success "iTerm2 configured to use custom preferences"
}

# Install iTerm2 shell integration
install_shell_integration() {
    print_info "Installing iTerm2 shell integration..."
    
    # Link shell integration file
    if [ -e "$HOME/.iterm2_shell_integration.zsh" ] || [ -L "$HOME/.iterm2_shell_integration.zsh" ]; then
        print_warning "Shell integration already exists. Backing up..."
        mv "$HOME/.iterm2_shell_integration.zsh" "$HOME/.iterm2_shell_integration.zsh.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    ln -sf "$DOTFILES_DIR/iterm2/iterm2_shell_integration.zsh" "$HOME/.iterm2_shell_integration.zsh"
    print_success "iTerm2 shell integration installed"
}

# Configure iTerm2 status bar
configure_status_bar() {
    print_info "Configuring iTerm2 status bar..."
    
    # The status bar configuration is already included in the plist file
    print_success "Status bar configuration included in profile"
    print_info "Status bar will show: Git branch, Git status, CPU, Memory, and Network"
}

# Main installation flow
main() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════╗"
    echo "║     iTerm2 Enhanced Setup Script       ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    
    install_iterm2
    import_iterm_profile
    configure_custom_prefs
    install_shell_integration
    configure_status_bar
    
    echo
    print_success "iTerm2 setup complete!"
    echo
    echo "Next steps:"
    echo "1. Open iTerm2"
    echo "2. Go to Preferences > General > Preferences"
    echo "3. Verify 'Load preferences from a custom folder' is checked"
    echo "4. Verify the path points to: $DOTFILES_DIR/iterm2"
    echo "5. Restart iTerm2 for all changes to take effect"
    echo
    echo "Features enabled:"
    echo "✓ Transparent background with blur"
    echo "✓ TokyoNight color scheme"
    echo "✓ Git information in status bar"
    echo "✓ System monitoring in status bar"
    echo "✓ Shell integration for better navigation"
    echo "✓ Semantic history (Cmd+Click on paths)"
    echo "✓ Triggers for error/warning/success highlighting"
    echo "✓ Optimized for Powerlevel10k prompt"
}

# Run main function
main