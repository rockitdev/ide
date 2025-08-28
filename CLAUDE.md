# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Status

This repository contains a complete dotfiles configuration for a portable Neovim IDE development environment with terminal transparency, Git integration, and Claude AI capabilities.

## Project Structure

```
dotfiles/
├── install.sh          # One-command installer script (entry point)
├── scripts/
│   └── setup.sh       # Core setup logic
├── nvim/              # Neovim configuration
│   ├── init.lua      # Main entry point
│   └── lua/
│       ├── config/   # Core settings (options, keymaps, transparency)
│       └── plugins/  # Plugin configs (ui, git, editor, coding, ai)
├── alacritty/        # Alacritty terminal configuration
├── wezterm/          # WezTerm configuration  
├── zsh/              # Zsh shell configuration
└── README.md         # Documentation
```

## Commands

### Installation
- **One-command install**: `curl -fsSL https://raw.githubusercontent.com/rockitdev/ide/main/install.sh | bash`
- **Local install**: `./install.sh` (interactive prompts for configuration)
- **Setup only**: `./scripts/setup.sh` (if dotfiles already cloned)

### Development
- **Launch Neovim**: `nvim`
- **Update plugins**: In Neovim, run `:Lazy sync`
- **Check health**: In Neovim, run `:checkhealth`
- **Mason LSP installer**: In Neovim, run `:Mason`

### Key Bindings (in Neovim)
- **Leader key**: Space
- **Claude chat**: `<leader>cc`
- **File explorer**: `<leader>e`
- **Find files**: `<leader>ff`
- **Live grep**: `<leader>/`
- **Git status**: `<leader>gs`

## Architecture

### Core Design Principles
1. **Portability**: Everything in a single git repo, one-command setup
2. **Transparency**: Terminal and editor background transparency for aesthetics
3. **Modularity**: Separated plugin configurations by concern
4. **AI Integration**: Native Claude AI support in editor

### Technology Stack
- **Editor**: Neovim with Lua configuration
- **Plugin Manager**: lazy.nvim (fast, lazy-loading)
- **Terminals**: Alacritty/WezTerm with transparency
- **Shell**: Zsh with Zinit plugin manager
- **Theme**: TokyoNight with transparency modifications
- **LSP**: Mason for automatic LSP installation
- **AI**: CodeCompanion.nvim for Claude integration

### Key Features
- Full LSP support with auto-completion
- Git integration (Fugitive, Gitsigns, Diffview)
- Fuzzy finding with Telescope
- File tree with Neo-tree
- Terminal integration with ToggleTerm
- Claude AI chat within Neovim
- Transparent backgrounds throughout