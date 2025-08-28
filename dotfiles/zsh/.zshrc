# Zsh configuration

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path configuration
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Completion
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt MENU_COMPLETE
setopt AUTO_MENU

# Environment variables
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export LESS='-R'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Claude API key (set this to your actual key)
# export ANTHROPIC_API_KEY="your-api-key-here"

# FZF configuration
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
  --color=bg+:#292e42,bg:#1a1b26,spinner:#bb9af7,hl:#7aa2f7
  --color=fg:#c0caf5,header:#7aa2f7,info:#e0af68,pointer:#bb9af7
  --color=marker:#9ece6a,fg+:#c0caf5,prompt:#7aa2f7,hl+:#7aa2f7
  --layout=reverse --border --height=40%
'

# Aliases
alias vim='nvim'
alias vi='nvim'
alias v='nvim'
alias nv='nvim'

# Git aliases
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias gs='git status'
alias gpl='git pull'

# Directory listing
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Claude CLI alias
alias claude='claude-code'
alias ai='claude-code'

# Docker aliases
alias d='docker'
alias dc='docker-compose'

# System info
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Functions

# Create and change to directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract archives
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar x "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick backup
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Git branch in prompt (if not using Powerlevel10k)
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Load zinit plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$(dirname $ZINIT_HOME)"
    command git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Load plugins
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# Keybindings
bindkey -e  # Emacs mode
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Load Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load local configuration if it exists
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Node Version Manager (if installed)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Rust (if installed)
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Python virtual environment
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
[[ -f /usr/local/bin/virtualenvwrapper.sh ]] && source /usr/local/bin/virtualenvwrapper.sh

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Start tmux automatically (optional)
# if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#   exec tmux new-session -A -s main
# fi