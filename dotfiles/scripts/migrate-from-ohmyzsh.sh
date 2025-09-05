#!/bin/bash

# Migration Script from Oh My Zsh to Enhanced Zsh Configuration
# Part of the Portable Neovim IDE Dotfiles

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Banner
echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════╗
║                                                  ║
║     MIGRATION FROM OH-MY-ZSH TO ENHANCED ZSH    ║
║                                                  ║
╚══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check current setup
print_info "Analyzing your current Oh My Zsh setup..."

# Backup current configuration
BACKUP_DIR="$HOME/.zsh-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

print_info "Creating backup in $BACKUP_DIR..."

# Backup files if they exist
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/" && print_success "Backed up .zshrc"
[ -d "$HOME/.oh-my-zsh" ] && print_info "Oh My Zsh installation found at ~/.oh-my-zsh"
[ -f "$HOME/.zshrc.pre-oh-my-zsh" ] && cp "$HOME/.zshrc.pre-oh-my-zsh" "$BACKUP_DIR/" && print_success "Backed up pre-oh-my-zsh config"

# Check for custom Oh My Zsh configurations
if [ -d "$HOME/.oh-my-zsh/custom" ]; then
    print_info "Found Oh My Zsh customizations..."
    cp -r "$HOME/.oh-my-zsh/custom" "$BACKUP_DIR/"
    print_success "Backed up Oh My Zsh custom directory"
fi

# Extract custom configurations from current .zshrc
print_info "Extracting your custom configurations..."

# Create a file for custom configurations
CUSTOM_CONFIG="$HOME/.zshrc.custom-migration"
echo "# Custom configurations migrated from Oh My Zsh" > "$CUSTOM_CONFIG"
echo "# Created on $(date)" >> "$CUSTOM_CONFIG"
echo "" >> "$CUSTOM_CONFIG"

# Extract custom aliases (lines starting with 'alias' but not in oh-my-zsh)
if grep -E "^alias " "$HOME/.zshrc" > /dev/null 2>&1; then
    echo "# Custom aliases" >> "$CUSTOM_CONFIG"
    grep -E "^alias " "$HOME/.zshrc" | grep -v "ohmyzsh\|zshconfig" >> "$CUSTOM_CONFIG" || true
    echo "" >> "$CUSTOM_CONFIG"
    print_success "Extracted custom aliases"
fi

# Extract custom functions
if grep -E "^[a-zA-Z_][a-zA-Z0-9_]*\(\)" "$HOME/.zshrc" > /dev/null 2>&1; then
    echo "# Custom functions" >> "$CUSTOM_CONFIG"
    # This is a simplified extraction - you may need to manually review
    print_warning "Please manually review functions in your original .zshrc"
fi

# Extract custom exports (excluding standard ones)
if grep -E "^export " "$HOME/.zshrc" | grep -v "ZSH\|PATH\|NVM\|LANG\|EDITOR" > /dev/null 2>&1; then
    echo "# Custom exports" >> "$CUSTOM_CONFIG"
    grep -E "^export " "$HOME/.zshrc" | grep -v "ZSH\|PATH\|NVM\|LANG\|EDITOR" >> "$CUSTOM_CONFIG" || true
    echo "" >> "$CUSTOM_CONFIG"
    print_success "Extracted custom exports"
fi

# Migration steps
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}MIGRATION PLAN:${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo ""

echo "1. Your current configuration has been backed up to:"
echo "   $BACKUP_DIR"
echo ""

echo "2. Custom configurations have been extracted to:"
echo "   $CUSTOM_CONFIG"
echo ""

echo "3. The new configuration includes everything from Oh My Zsh plus:"
echo "   ✓ Faster startup with Zinit (vs Oh My Zsh)"
echo "   ✓ Powerlevel10k theme (vs robbyrussell)"
echo "   ✓ 30+ productivity plugins (vs just git)"
echo "   ✓ 100+ aliases and functions"
echo "   ✓ Full-stack development tools"
echo "   ✓ Your SSH agent configuration"
echo ""

echo "4. To complete the migration, run:"
echo -e "   ${GREEN}./dotfiles/install.sh${NC}"
echo ""

echo "5. After installation:"
echo "   a) Review $CUSTOM_CONFIG"
echo "   b) Add any missing custom configs to ~/.zshrc.local"
echo "   c) Your SSH keys will be automatically loaded"
echo ""

# Comparison
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}FEATURE COMPARISON:${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo ""
printf "%-30s %-20s %-20s\n" "Feature" "Oh My Zsh" "New Config"
printf "%-30s %-20s %-20s\n" "------" "---------" "----------"
printf "%-30s %-20s %-20s\n" "Plugin Manager" "Oh My Zsh" "Zinit (faster)"
printf "%-30s %-20s %-20s\n" "Theme" "robbyrussell" "Powerlevel10k"
printf "%-30s %-20s %-20s\n" "Plugins" "1 (git)" "30+"
printf "%-30s %-20s %-20s\n" "Git Integration" "Basic" "Advanced"
printf "%-30s %-20s %-20s\n" "Auto-suggestions" "No" "Yes"
printf "%-30s %-20s %-20s\n" "Syntax Highlighting" "No" "Yes"
printf "%-30s %-20s %-20s\n" "Fuzzy Search" "No" "Yes (fzf)"
printf "%-30s %-20s %-20s\n" "Database Tools" "No" "Yes"
printf "%-30s %-20s %-20s\n" "API Testing" "No" "Yes"
printf "%-30s %-20s %-20s\n" "Cloud Tools" "No" "Yes"
printf "%-30s %-20s %-20s\n" "Tmux Integration" "No" "Yes"
printf "%-30s %-20s %-20s\n" "SSH Agent" "Manual" "Automatic"
echo ""

# Ask for confirmation
echo -e "${YELLOW}════════════════════════════════════════════════════${NC}"
read -p "Ready to proceed with migration? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_success "Great! Run ./dotfiles/install.sh to complete the migration"
    
    # Create a migration notes file
    cat > "$HOME/.migration-notes.txt" << EOF
MIGRATION NOTES - $(date)
========================

1. Original .zshrc backed up to: $BACKUP_DIR/.zshrc
2. Custom configs extracted to: $CUSTOM_CONFIG
3. Oh My Zsh directory: ~/.oh-my-zsh (can be removed after migration)

After successful migration:
- Test all your commonly used commands
- Verify SSH keys are loading correctly
- Check that custom aliases work
- Run 'p10k configure' to customize your prompt

To rollback if needed:
cp $BACKUP_DIR/.zshrc ~/.zshrc
source ~/.zshrc

To remove Oh My Zsh after successful migration:
rm -rf ~/.oh-my-zsh
rm -f ~/.zshrc.pre-oh-my-zsh
EOF
    
    print_success "Migration notes saved to ~/.migration-notes.txt"
else
    print_info "Migration cancelled. Your configuration remains unchanged."
fi