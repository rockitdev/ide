# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a portable Neovim IDE configuration with an enhanced terminal experience featuring:
- **Powerlevel10k prompt** with Git status indicators
- **Terminal transparency** and modern aesthetics
- **30+ terminal enhancements** including syntax highlighting, autosuggestions, and fuzzy search
- **iTerm2 integration** with custom status bar and shell integration
- **AI capabilities** with Claude integration
- **One-command installer** for complete development environment

## Project Structure

```
ide/
├── dotfiles/                   # Main dotfiles directory
│   ├── install.sh             # Primary installer script (entry point)
│   ├── one-liner.sh           # Alternative one-command installer
│   ├── scripts/
│   │   ├── setup.sh           # Core setup logic and configuration
│   │   └── setup-iterm.sh    # iTerm2 specific setup (macOS)
│   ├── nvim/                  # Neovim configuration
│   │   ├── init.lua           # Main Neovim entry point
│   │   ├── after/             # After-load configurations
│   │   └── lua/
│   │       ├── config/        # Core settings
│   │       │   ├── options.lua      # Editor options
│   │       │   ├── keymaps.lua      # Key mappings
│   │       │   └── transparency.lua # Transparency settings
│   │       └── plugins/       # Plugin configurations
│   │           ├── ui.lua           # UI/theme plugins
│   │           ├── editor.lua       # Editor enhancements
│   │           ├── git.lua          # Git integration
│   │           ├── coding.lua       # LSP, completion, treesitter
│   │           └── ai.lua           # AI/Claude integration
│   ├── alacritty/            # Alacritty terminal config
│   │   └── alacritty.toml    # Terminal settings with transparency
│   ├── wezterm/              # WezTerm configuration
│   │   └── wezterm.lua       # Lua-based terminal config
│   ├── zsh/                  # Enhanced Zsh configuration
│   │   ├── .zshrc            # Main Zsh config with 30+ features
│   │   └── .p10k.zsh         # Powerlevel10k theme configuration
│   ├── iterm2/               # iTerm2 configuration (macOS)
│   │   ├── com.googlecode.iterm2.plist  # iTerm2 preferences
│   │   └── iterm2_shell_integration.zsh # Shell integration
│   └── README.md             # Comprehensive documentation
├── .claude/                  # Claude Code settings
│   └── settings.local.json   # Local Claude settings
└── CLAUDE.md                 # This file
```

## Installation Commands

### Primary Installation Methods
- **One-command install**: `curl -fsSL https://raw.githubusercontent.com/rockitdev/ide/main/install.sh | bash`
- **Local install**: `./dotfiles/install.sh` (interactive prompts)
- **Setup only**: `./dotfiles/scripts/setup.sh` (if already cloned)
- **iTerm2 setup**: `./dotfiles/scripts/setup-iterm.sh` (macOS only)

### Development Commands
- **Launch Neovim**: `nvim`
- **Update plugins**: `:Lazy sync` (in Neovim)
- **Check health**: `:checkhealth` (in Neovim)
- **Mason LSP installer**: `:Mason` (in Neovim)
- **Plugin manager**: `:Lazy` (in Neovim)

## Key Bindings (Neovim)

### Essential Mappings
- **Leader key**: Space
- **Claude chat**: `<leader>cc`
- **File explorer**: `<leader>e`
- **Find files**: `<leader>ff`
- **Live grep**: `<leader>/`
- **Git status**: `<leader>gs`
- **Git diff**: `<leader>gd`
- **Git blame**: `<leader>gb`
- **Lazy plugin manager**: `<leader>l`

### Window Navigation
- **Navigate windows**: `<C-h/j/k/l>`
- **Resize windows**: `<C-arrows>`
- **Navigate buffers**: `<S-h/l>`

### Code Navigation
- **Go to definition**: `gd`
- **Find references**: `gr`
- **Hover documentation**: `K`
- **Previous/Next diagnostic**: `[d` / `]d`
- **Flash jump**: `s`

## Architecture & Design

### Core Design Principles
1. **Portability**: Single git repository with one-command setup
2. **Transparency**: Terminal and editor background transparency throughout
3. **Modularity**: Separated plugin configurations by functional concern
4. **AI Integration**: Native Claude AI support within the editor
5. **Performance**: Lazy-loading plugins for fast startup

### Technology Stack
- **Editor**: Neovim 0.9+ with Lua configuration
- **Plugin Manager**: lazy.nvim (automatic lazy-loading)
- **Terminals**: Alacritty/WezTerm with transparency support
- **Shell**: Zsh with Zinit plugin manager
- **Theme**: TokyoNight with custom transparency modifications
- **LSP Management**: Mason for automatic LSP installation
- **AI Integration**: CodeCompanion.nvim for Claude/GPT

### Key Features
- Full LSP support with auto-completion (nvim-cmp)
- Git integration (Fugitive, Gitsigns, Diffview, Octo)
- Fuzzy finding with Telescope
- File tree with Neo-tree
- Terminal integration with ToggleTerm
- Claude AI chat and code assistance
- Transparent backgrounds throughout
- Session management with auto-session
- Syntax highlighting with Treesitter

## Configuration Files

### Installer Scripts
- `dotfiles/install.sh`: Main installer with OS detection, package installation, interactive setup
- `dotfiles/scripts/setup.sh`: Core setup logic, symlink creation, configuration deployment
- `dotfiles/one-liner.sh`: Alternative one-command installer wrapper

### Neovim Configuration
- `dotfiles/nvim/init.lua`: Entry point, loads lazy.nvim and plugins
- `dotfiles/nvim/lua/config/options.lua`: Editor settings and options
- `dotfiles/nvim/lua/config/keymaps.lua`: Key mappings and shortcuts
- `dotfiles/nvim/lua/config/transparency.lua`: Transparency configuration
- `dotfiles/nvim/lua/plugins/*.lua`: Modular plugin configurations

### Terminal Configurations
- `dotfiles/alacritty/alacritty.toml`: Alacritty settings with transparency
- `dotfiles/wezterm/wezterm.lua`: WezTerm Lua configuration

### Shell Configuration
- `dotfiles/zsh/`: Zsh configuration files
- `~/.zshrc.local`: Local environment variables (created by installer, not tracked)

## Environment Variables

### Required for AI Features
- `ANTHROPIC_API_KEY`: Claude API key (stored in ~/.zshrc.local)
- `OPENAI_API_KEY`: OpenAI API key (optional, for GPT support)

### Installation Variables
- `GITHUB_USERNAME`: GitHub username for repo cloning (default: rockitdev)
- `REPO_NAME`: Repository name (default: ide)
- `DOTFILES_DIR`: Installation directory (default: ~/ide)
- `INSTALL_DIR`: Target directory for symlinks (default: ~)

## Language Support

### Pre-configured LSP Servers
- **Lua**: lua_ls
- **TypeScript/JavaScript**: tsserver
- **Python**: pyright
- **Rust**: rust_analyzer
- **Go**: gopls
- **HTML/CSS**: html, cssls
- **JSON**: jsonls
- **Bash**: bashls

Additional servers can be installed via Mason (`:Mason` in Neovim).

## Testing & Validation

### Health Checks
- Run `:checkhealth` in Neovim to verify setup
- Check `:Lazy` for plugin installation status
- Verify LSP with `:LspInfo`
- Test Claude integration with `<leader>cc`

### Common Issues & Solutions
1. **Fonts not rendering**: Install a Nerd Font (JetBrainsMono Nerd Font recommended)
2. **Transparency not working**: Ensure terminal supports transparency and compositor is running
3. **Claude not responding**: Verify ANTHROPIC_API_KEY is set in ~/.zshrc.local
4. **Plugins not loading**: Run `:Lazy sync` to update/install plugins
5. **LSP not working**: Run `:Mason` to install language servers

## Development Guidelines

### When Modifying This Repository
1. **Maintain modularity**: Keep plugin configurations separated by concern
2. **Preserve transparency**: Ensure all UI changes respect transparency settings
3. **Document changes**: Update README.md for user-facing changes
4. **Test installation**: Verify the one-command installer still works
5. **Keep it portable**: Avoid system-specific dependencies when possible

### Adding New Plugins
1. Add to appropriate file in `dotfiles/nvim/lua/plugins/`
2. Use lazy-loading where appropriate (`event = "VeryLazy"`)
3. Include clear comments explaining the plugin's purpose
4. Test with fresh installation

### Security Considerations
- Never commit API keys or secrets
- Use ~/.zshrc.local for sensitive environment variables
- The installer should handle API key input securely (hidden input)
- All local configuration files should be gitignored

## Terminal Features (30+ Enhancements)

### Git & Version Control
1. **Git branch in prompt** - Current branch, dirty status, ahead/behind indicators
2. **Git status indicators** - Visual symbols for staged, modified, untracked files
3. **Auto-fetch background** - Periodically fetches git updates
4. **Git commit graph** - Beautiful commit history visualization (`gll` alias)
5. **Git auto-completion** - Enhanced tab completion for git commands

### Prompt & Theme
6. **Powerlevel10k theme** - Fast, customizable prompt with icons
7. **Command execution time** - Shows how long commands took
8. **Exit code indicator** - Visual indicator when commands fail
9. **Directory shortening** - Smart path truncation in prompt
10. **Context awareness** - Shows Python venv, Node version, Docker context

### Productivity Tools
11. **Syntax highlighting** - Commands colorized as you type (zsh-syntax-highlighting)
12. **Auto-suggestions** - Fish-like suggestions based on history (zsh-autosuggestions)
13. **Fuzzy history search** - Search command history with fzf (Ctrl+R)
14. **Directory jumping** - Quick navigation with zoxide (`z` command)
15. **Smart aliases** - 100+ aliases for common commands

### File & Directory
16. **Colorized ls** - eza with icons and git status
17. **Tree view** - Beautiful directory trees with icons
18. **File previews** - bat for syntax-highlighted cat
19. **Directory bookmarks** - Quick jumps to frequent directories
20. **Auto-ls on cd** - Automatically lists files when changing directories

### Enhanced Features
21. **Command corrections** - Suggests fixes for typos (thefuck)
22. **Directory history** - Navigate back/forward through directories
23. **Clipboard integration** - System clipboard integration
24. **SSH completion** - Auto-complete SSH hostnames
25. **Docker completion** - Enhanced Docker command completion

### iTerm2-Specific (macOS)
26. **Shell integration** - Marks, badges, and navigation
27. **Status bar** - Git info, CPU, memory, network in status bar
28. **Semantic history** - Cmd+click on paths to open them
29. **Triggers & badges** - Visual notifications for errors/warnings/success
30. **Split pane workflows** - Optimized hotkeys and layouts

## Project Goals

1. **Zero-to-IDE**: One command to full development environment
2. **Beautiful**: Transparent, modern aesthetics with 30+ terminal enhancements
3. **Fast**: Optimized startup and runtime performance
4. **AI-Native**: Integrated AI assistance for modern development
5. **Portable**: Works across macOS and Linux distributions
6. **Maintainable**: Clear structure and documentation

## Repository Information

- **Primary Repository**: https://github.com/rockitdev/ide
- **Installation URL**: https://raw.githubusercontent.com/rockitdev/ide/main/install.sh
- **Documentation**: See README.md for comprehensive user documentation
- **License**: MIT (open source)

## Important Notes

- This is a dotfiles configuration repository, not application code
- The installer is designed to be idempotent (safe to run multiple times)
- All configurations are symlinked from ~/ide to appropriate locations
- Local customizations go in ~/.zshrc.local (not tracked by git)
- The project prioritizes developer experience and productivity