# 🚀 Portable Neovim IDE with Cyberpunk Terminal

A complete development environment featuring Neovim IDE, cyberpunk-themed terminal with 30+ enhancements, and full-stack developer tooling. One command installs everything.

![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)
![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

## ✨ Features

- **🎨 Cyberpunk Terminal**: Neon-colored Powerlevel10k prompt with transparent backgrounds
- **🤖 AI Integration**: Claude AI chat and code assistance directly in Neovim
- **🔧 Full-Stack Ready**: Complete tooling for modern web development
- **⚡ 30+ Terminal Enhancements**: Git status, fuzzy search, auto-suggestions, and more
- **🌐 Cross-Platform**: Works on macOS and Linux with one-command setup
- **🔒 Secure**: API keys stored locally, never committed to version control

## 🚀 Quick Installation

### New Computer Setup (Fresh Install)

**One-command installation** - Just run this and follow the prompts:

```bash
curl -fsSL https://raw.githubusercontent.com/rockitdev/ide/main/install.sh | bash
```

Or with `wget`:
```bash
wget -qO- https://raw.githubusercontent.com/rockitdev/ide/main/install.sh | bash
```

### Existing Computer Setup

If you already have development tools installed:

```bash
# Clone and run locally to avoid conflicts
git clone https://github.com/rockitdev/ide.git ~/ide
cd ~/ide
./dotfiles/install.sh
```

### Advanced Installation Options

**Custom GitHub username:**
```bash
GITHUB_USERNAME="your-username" curl -fsSL https://raw.githubusercontent.com/rockitdev/ide/main/install.sh | bash
```

**Silent installation (no prompts):**
```bash
curl -fsSL https://raw.githubusercontent.com/rockitdev/ide/main/install.sh | bash -s -- --silent
```

**Update existing installation:**
```bash
cd ~/ide
git pull origin main
./dotfiles/scripts/setup.sh
```

## 🎯 What Gets Installed

### System Packages (Auto-detected by OS)

**macOS (via Homebrew):**
- Neovim, Git, Node.js, Python, Rust
- Alacritty, WezTerm, iTerm2 integration
- FZF, Ripgrep, Eza, Zoxide, Bat

**Linux (via package manager):**
- Same core packages adapted for your distribution
- Ubuntu/Debian, Arch, Fedora automatically detected

### Terminal Enhancement (30+ Features)

#### **Cyberpunk Powerlevel10k Prompt**
- 🌈 **Neon colors**: Hot pink, electric cyan, matrix green, neon purple
- ⏱️ **Command timing**: Shows execution time for slow commands
- 📂 **Smart directory**: Path shortening with Git status
- 🔄 **Git integration**: Branch, status, ahead/behind indicators
- 🐍 **Environment context**: Python venv, Node version, Docker

#### **Productivity Tools**
- 🎨 **Syntax highlighting**: Commands colorized as you type
- 🐟 **Auto-suggestions**: Fish-like command suggestions
- 🔍 **Fuzzy search**: FZF for files, history, processes
- 🦘 **Directory jumping**: Zoxide for smart `cd`
- 📋 **Clipboard integration**: System clipboard support

#### **Developer Workflow**
- 🔧 **100+ aliases**: Smart shortcuts for common commands
- 📝 **Enhanced `ls`**: Eza with icons and Git status
- 🌳 **Tree views**: Beautiful directory trees
- 🦇 **Better `cat`**: Bat with syntax highlighting
- 🔗 **SSH management**: Key loading and connection helpers

### Neovim IDE Configuration

#### **Core Editor**
- **Theme**: TokyoNight with transparency support
- **Plugin Manager**: Lazy.nvim with optimized loading
- **LSP**: Mason for automatic language server installation
- **Completion**: nvim-cmp with AI-powered suggestions

#### **AI Integration**
- **Claude AI**: CodeCompanion.nvim for chat and code assistance
- **Terminal AI**: Integrated Claude CLI for terminal usage
- **Code Generation**: AI-powered code completion and refactoring

#### **Git Powerhouse**
- **Fugitive**: Premier Git integration
- **Gitsigns**: Inline Git decorations
- **Diffview**: Beautiful diff visualization
- **Octo**: GitHub issues and PRs in Neovim

## ⌨️ Key Bindings

### Leader Key: `Space`

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>cc` | Claude Chat | Open AI chat window |
| `<leader>ca` | Claude Actions | AI code actions menu |
| `<leader>e` | File Explorer | Toggle Neo-tree |
| `<leader>ff` | Find Files | Telescope file finder |
| `<leader>/` | Live Grep | Search in project |
| `<leader>gs` | Git Status | Fugitive status |
| `<leader>gd` | Git Diff | View file changes |
| `<leader>gb` | Git Blame | Inline blame annotations |
| `<leader>l` | Lazy | Plugin manager |

### Navigation & Workflow

| Keybinding | Action |
|------------|--------|
| `<C-h/j/k/l>` | Navigate windows |
| `<C-arrows>` | Resize windows |
| `<S-h/l>` | Navigate buffers |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `s` | Flash jump (quick navigation) |

## 🛠️ Installation Details

### What the Installer Does

1. **🔍 System Detection**: Automatically detects your OS and package manager
2. **📦 Package Installation**: Installs all required development tools
3. **🔗 Symlink Creation**: Links dotfiles to appropriate locations:
   ```
   ~/ide/dotfiles/nvim     → ~/.config/nvim
   ~/ide/dotfiles/zsh      → ~/.config/zsh
   ~/ide/dotfiles/alacritty → ~/.config/alacritty
   ~/ide/dotfiles/wezterm  → ~/.config/wezterm
   ```
4. **🎨 Terminal Setup**: Configures terminal with transparency and themes
5. **🔐 Secure API Setup**: Prompts for API keys and stores in `~/.zshrc.local`
6. **✨ Shell Enhancement**: Sets up Zsh with Zinit plugin manager
7. **🖥️ iTerm2 Integration**: Configures status bar and shell integration (macOS)

### Directory Structure After Installation

```
~/ide/                          # Main installation directory
├── dotfiles/                   # Dotfiles (symlinked to ~/.config/)
│   ├── nvim/                   # Neovim configuration
│   │   ├── init.lua            # Entry point
│   │   └── lua/
│   │       ├── config/         # Core settings
│   │       └── plugins/        # Plugin configurations
│   ├── zsh/                    # Shell configuration
│   │   ├── .zshrc              # Main config with 30+ features
│   │   └── .p10k.zsh           # Cyberpunk theme config
│   ├── alacritty/              # Terminal config
│   ├── wezterm/                # Alternative terminal
│   └── scripts/                # Setup and utility scripts
└── README.md                   # This file

~/.zshrc                        # Sources ~/ide/dotfiles/zsh/.zshrc
~/.zshrc.local                  # Local config (API keys, not tracked)
```

## 🎨 Customization

### Terminal Colors & Theme

The cyberpunk theme uses these neon colors:
- **Hot Pink** (`#FF0066`): Error states, root user
- **Electric Cyan** (`#00FFFF`): Success states, timestamps  
- **Matrix Green** (`#00FF00`): Python environments
- **Neon Purple** (`#9966CC`): Git status
- **Neon Orange** (`#FF6600`): Directory paths
- **Electric Blue** (`#0066FF`): User context

### Modifying Colors

Edit `~/ide/dotfiles/zsh/.p10k.zsh`:
```bash
# Cyberpunk neon colors
local neon_pink='198'     # Hot neon pink
local neon_cyan='51'      # Electric cyan  
local neon_green='46'     # Matrix green
# ... modify as desired
```

### Adding Terminal Enhancements

Edit `~/ide/dotfiles/zsh/.zshrc` to add:
- New aliases: `alias myalias='command'`
- Functions: `function name() { ... }`
- Environment variables: `export VAR=value`

### Neovim Plugin Management

Add plugins in `~/ide/dotfiles/nvim/lua/plugins/`:
```lua
-- New plugin example
{
  "author/plugin-name",
  event = "VeryLazy",      -- Lazy load
  keys = "<leader>key",    -- Load on keypress
  opts = {
    -- plugin configuration
  },
}
```

## 🔐 API Key Setup

### Claude AI Integration

1. **Get API Key**: Visit [Anthropic Console](https://console.anthropic.com/)
2. **Installation Prompt**: The installer will securely prompt for your key
3. **Manual Setup**: Or add to `~/.zshrc.local`:
   ```bash
   export ANTHROPIC_API_KEY="your-actual-key-here"
   ```

### Security Notes

- API keys stored in `~/.zshrc.local` (not tracked by Git)
- Input is hidden during installation
- Keys never committed to version control
- Local configuration file is automatically gitignored

## 🌍 Language Support

### Pre-configured LSP Servers

Languages with automatic LSP setup:
- **JavaScript/TypeScript**: tsserver, ESLint, Prettier
- **Python**: pyright, black, isort, ruff
- **Rust**: rust_analyzer, rustfmt
- **Go**: gopls, gofmt, goimports
- **Lua**: lua_ls, stylua
- **HTML/CSS**: html, cssls, prettier
- **JSON/YAML**: jsonls, yamlls
- **Bash/Shell**: bashls, shellcheck

### Adding Language Support

Use Mason in Neovim:
```vim
:Mason                    # Open LSP installer
:MasonInstall pyright     # Install specific LSP
:LspInfo                  # Check LSP status
```

## 🚀 Full-Stack Development

### Database Tools

Pre-configured connections and tools:
```bash
dbc postgres              # Connect to PostgreSQL
dbc mysql                 # Connect to MySQL  
dbc mongo                 # Connect to MongoDB
dbc redis                 # Connect to Redis
```

### API Development

Built-in API testing:
```bash
api get https://api.example.com/users
api post https://api.example.com/users '{"name":"test"}'
http GET httpie.io/hello  # HTTPie integration
```

### Project Management

Quick project setup:
```bash
pnew react my-app         # Create React project
pnew nextjs my-site       # Create Next.js site
pnew node my-api          # Create Node.js API
psw                       # Switch between projects
```

### Cloud Integration

Pre-configured cloud tools:
```bash
k get pods                # Kubernetes (kubectl)
aws s3 ls                 # AWS CLI
gcloud projects list      # Google Cloud
az account list           # Azure CLI
```

## 🐛 Troubleshooting

### Common Issues

#### **Fonts not displaying properly**
```bash
# Install Nerd Fonts
brew install font-jetbrains-mono-nerd-font  # macOS
# Or download from: https://github.com/ryanoasis/nerd-fonts
```

#### **Neovim plugins not loading**
```bash
nvim --headless "+Lazy! sync" +qa  # Force plugin sync
# In Neovim:
:checkhealth                       # Check system health
:Lazy                             # Open plugin manager
```

#### **Claude AI not responding**
```bash
echo $ANTHROPIC_API_KEY           # Verify key is set
# Add to ~/.zshrc.local if missing:
export ANTHROPIC_API_KEY="your-key"
source ~/.zshrc.local
```

#### **Terminal colors not working**
```bash
# Check terminal true color support:
echo $TERM
# Should show: xterm-256color or similar
# In Neovim check: :checkhealth
```

#### **Zsh not loading enhancements**
```bash
# Check if zsh is default shell:
echo $SHELL                       # Should be /bin/zsh
chsh -s /bin/zsh                 # Change default shell
```

### Reset Installation

If something goes wrong:
```bash
# Remove symlinks and reinstall
rm ~/.config/nvim ~/.config/alacritty ~/.config/wezterm
cd ~/ide && git pull origin main
./dotfiles/scripts/setup.sh
```

## 📊 Performance

### Startup Times

- **Zsh shell**: ~100ms (with all enhancements)
- **Neovim**: ~50ms (with lazy loading)
- **Plugin loading**: Deferred until needed

### System Requirements

- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 2GB for complete installation
- **Terminal**: True color support required
- **Network**: Internet connection for initial setup

## 🤝 Contributing

We welcome contributions! Here's how:

1. **Fork**: Click the fork button on GitHub
2. **Clone**: `git clone https://github.com/YOUR-USERNAME/ide.git`
3. **Branch**: `git checkout -b feature/amazing-feature`
4. **Develop**: Make your changes
5. **Test**: Test on fresh system if possible
6. **Commit**: `git commit -m 'Add amazing feature'`
7. **Push**: `git push origin feature/amazing-feature`
8. **PR**: Open a Pull Request

### Development Guidelines

- Keep the one-command installer working
- Maintain cross-platform compatibility
- Document new features
- Test with fresh installations
- Follow the existing code style

## 📄 License

MIT License - feel free to use, modify, and share!

## 🙏 Acknowledgments

- **Neovim Community**: For the amazing editor and plugins
- **Anthropic**: For Claude AI integration
- **Powerlevel10k**: For the beautiful terminal theme
- **All Plugin Authors**: Who make this setup possible

---

## ⭐ Support This Project

If this setup helps your development workflow:

1. **Star this repository** ⭐
2. **Share with fellow developers** 🤝
3. **Report bugs and suggest features** 🐛
4. **Contribute improvements** 💪

---

<p align="center">
  <strong>Built with ❤️ for developers who love beautiful, functional terminals</strong>
</p>

<p align="center">
  <a href="#-quick-installation">🚀 Get Started</a> •
  <a href="#-key-bindings">⌨️ Keybindings</a> •
  <a href="#-troubleshooting">🐛 Help</a> •
  <a href="#-contributing">🤝 Contribute</a>
</p>