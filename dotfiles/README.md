# 🚀 Portable Neovim IDE Dotfiles

A highly customized, portable development environment centered around Neovim with transparent terminal aesthetics, Git integration, and Claude AI capabilities.

![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)
![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

## ✨ Features

- **Neovim IDE**: Full-featured IDE with LSP, completion, Git integration, and AI assistance
- **Transparent Aesthetics**: Beautiful transparent terminal and editor backgrounds
- **AI Integration**: Claude AI chat and code assistance directly in Neovim
- **Git Powerhouse**: Advanced Git integration with Fugitive, Gitsigns, and GitHub CLI
- **Modern Terminal**: Choice of Alacritty or WezTerm with custom configurations
- **Plugin Management**: Lazy.nvim for fast and efficient plugin loading
- **Automated Setup**: One-command installation script for all platforms

## 📸 Screenshots

*Your beautiful transparent IDE setup here*

## 🎯 Quick Start

### 🚀 One-Command Installation

Just run this single command and follow the interactive prompts:

```bash
curl -fsSL https://raw.githubusercontent.com/rockitdev/ide/main/install.sh | bash
```

Or with `wget`:
```bash
wget -qO- https://raw.githubusercontent.com/rockitdev/ide/main/install.sh | bash
```

That's it! The installer will:
- 🔍 Detect your OS and distribution
- 📦 Install all required packages
- 🎨 Set up terminals with transparency
- ⚙️ Configure Neovim with all plugins
- 🔐 Prompt for your API keys securely
- 🔗 Create all necessary symlinks
- ✨ Set up your shell environment

### Alternative Installation Methods

**With custom GitHub username:**
```bash
GITHUB_USERNAME="your-github" curl -fsSL https://raw.githubusercontent.com/rockitdev/ide/main/install.sh | bash
```

**Clone and run locally (if you want to inspect first):**
```bash
git clone https://github.com/rockitdev/ide.git ~/ide
~/ide/install.sh
```

**Silent installation with all defaults:**
```bash
curl -fsSL https://raw.githubusercontent.com/rockitdev/ide/main/install.sh | bash -s -- --silent
```

## 📦 What's Included

### Core Components

- **Neovim** - Hyperextensible Vim-based text editor
- **Alacritty/WezTerm** - GPU-accelerated terminal emulators
- **Zsh + Zinit** - Modern shell with plugin management
- **Powerlevel10k** - Gorgeous Zsh theme
- **FZF** - Fuzzy finder for files and commands
- **Ripgrep** - Lightning-fast search tool

### Neovim Plugins

#### UI & Aesthetics
- `tokyonight.nvim` - Beautiful dark theme with transparency support
- `lualine.nvim` - Fast statusline
- `bufferline.nvim` - VSCode-like buffer tabs
- `alpha-nvim` - Gorgeous startup dashboard
- `nvim-web-devicons` - File type icons

#### Editor Enhancement
- `telescope.nvim` - Fuzzy finder and picker
- `neo-tree.nvim` - File explorer
- `which-key.nvim` - Keybinding helper
- `flash.nvim` - Lightning-fast navigation
- `trouble.nvim` - Pretty diagnostics list

#### Git Integration
- `gitsigns.nvim` - Git decorations and hunks
- `vim-fugitive` - Premier Git plugin
- `git-blame.nvim` - Inline blame annotations
- `diffview.nvim` - Single tabpage for all diffs
- `octo.nvim` - GitHub issues and PRs

#### Code Intelligence
- `nvim-lspconfig` - LSP configurations
- `nvim-treesitter` - Syntax highlighting and more
- `nvim-cmp` - Autocompletion engine
- `mason.nvim` - LSP/DAP/linter installer
- `Comment.nvim` - Smart commenting

#### AI Integration
- `codecompanion.nvim` - Claude/GPT integration
- `toggleterm.nvim` - Terminal integration for Claude CLI

## ⌨️ Key Mappings

### Leader Key: `Space`

| Key | Action | Mode |
|-----|--------|------|
| `<leader>cc` | Toggle Claude Chat | n, v |
| `<leader>ca` | Claude Actions | n, v |
| `<leader>e` | Toggle File Explorer | n |
| `<leader>ff` | Find Files | n |
| `<leader>/` | Live Grep | n |
| `<leader>gs` | Git Status | n |
| `<leader>gd` | Git Diff | n |
| `<leader>gb` | Git Blame | n |
| `<leader>l` | Lazy Plugin Manager | n |

### Window Management

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Navigate windows |
| `<C-arrows>` | Resize windows |
| `<S-h/l>` | Navigate buffers |

### Code Navigation

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `[d / ]d` | Previous/Next diagnostic |
| `s` | Flash jump |

## 🎨 Customization

### Terminal Transparency

Adjust transparency in terminal configs:

**Alacritty** (`~/.config/alacritty/alacritty.toml`):
```toml
[window]
opacity = 0.85  # Adjust between 0.0 and 1.0
```

**WezTerm** (`~/.config/wezterm/wezterm.lua`):
```lua
config.window_background_opacity = 0.85  -- Adjust between 0.0 and 1.0
```

### Adding Plugins

Edit `~/ide/nvim/lua/plugins/` files to add new plugins:

```lua
-- Example: Add a new plugin
{
  "username/plugin-name",
  event = "VeryLazy",
  opts = {
    -- plugin options
  },
}
```

### Claude AI Setup

1. Get your API key from [Anthropic Console](https://console.anthropic.com/)
2. The installer will prompt you for the API key (input is hidden)
3. Or manually add to `~/.zshrc.local` (not tracked by git):
```bash
export ANTHROPIC_API_KEY="your-actual-key-here"
```
**⚠️ Security Note**: Never commit API keys to version control. The installer stores them in `~/.zshrc.local` which is gitignored.

4. In Neovim, use `<leader>cc` to open Claude chat

## 🔧 Requirements

### System Requirements

- **macOS** 11+ / **Linux** (Ubuntu 20.04+, Arch, Fedora 34+)
- **Git** 2.25+
- **Node.js** 16+ (for LSP servers)
- **Python** 3.8+ (for Python development)
- Terminal with true color support

### Font Requirements

Install a Nerd Font for proper icon display:
- [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases) (recommended)
- [Hack Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases)
- [FiraCode Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases)

## 📝 Language Support

The setup includes LSP configurations for:

- **Lua** (lua_ls)
- **TypeScript/JavaScript** (tsserver)
- **Python** (pyright)
- **Rust** (rust_analyzer)
- **Go** (gopls)
- **HTML/CSS** (html, cssls)
- **JSON** (jsonls)
- **Bash** (bashls)

Additional language servers can be installed via `:Mason` in Neovim.

## 🚀 Advanced Usage

### Using Claude in Terminal

```bash
# Open Claude terminal
nvim
# Press <leader>tc

# Or from shell
claude-code
# or
ai
```

### Git Workflow

```bash
# In Neovim
:Git status       # View git status
:Git add %        # Stage current file
:Git commit       # Commit changes
:Gdiffsplit       # View diff in split

# Or use keybindings
<leader>gs        # Git status
<leader>gd        # Git diff
<leader>gb        # Git blame
```

### Session Management

The setup includes session management via `auto-session`:

```vim
:SessionSave      " Save current session
:SessionRestore   " Restore session
```

## 🐛 Troubleshooting

### Neovim plugins not installing

```bash
nvim --headless "+Lazy! sync" +qa
```

### Fonts not displaying correctly

Ensure your terminal is using a Nerd Font:
- **Alacritty**: Check `font.normal.family` in config
- **WezTerm**: Check `config.font` in config
- **Other terminals**: Set in terminal preferences

### Claude AI not working

1. Verify API key is set: `echo $ANTHROPIC_API_KEY`
2. Check plugin installation: `:Lazy` in Neovim
3. Try reinstalling: `:Lazy update codecompanion.nvim`

### Performance issues

1. Disable unused plugins in `~/ide/nvim/lua/plugins/`
2. Reduce transparency effects
3. Check `:checkhealth` in Neovim

## 📚 Resources

- [Neovim Documentation](https://neovim.io/doc/)
- [Lazy.nvim Guide](https://github.com/folke/lazy.nvim)
- [Claude API Documentation](https://docs.anthropic.com/)
- [My Blog Post About This Setup](#) *(Add your blog link)*

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- The Neovim community for amazing plugins
- Anthropic for Claude AI
- All the plugin authors whose work makes this possible

---

<p align="center">
  Made with ❤️ and lots of ☕
</p>

<p align="center">
  <a href="https://github.com/rockitdev/ide">⭐ Star this repository if you find it helpful!</a>
</p>