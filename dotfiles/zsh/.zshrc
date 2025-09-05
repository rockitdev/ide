#!/usr/bin/env zsh
# Enhanced Zsh Configuration with Powerlevel10k and awesome features
# Part of the Portable Neovim IDE Dotfiles

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# COMPATIBILITY SETTINGS
# ============================================================================

# Disable magic functions (fixes URL pasting issues)
DISABLE_MAGIC_FUNCTIONS="true"

# ============================================================================
# ZINIT PLUGIN MANAGER
# ============================================================================

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# ============================================================================
# THEME - Powerlevel10k
# ============================================================================

zinit ice depth=1; zinit light romkatv/powerlevel10k

# ============================================================================
# PLUGINS
# ============================================================================

# Git extras and enhancements
zinit light paulirish/git-open
zinit light wfxr/forgit

# Syntax highlighting (load before autosuggestions)
zinit light zsh-users/zsh-syntax-highlighting

# Autosuggestions (fish-like)
zinit light zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# Completions
zinit light zsh-users/zsh-completions

# History substring search
zinit light zsh-users/zsh-history-substring-search

# Command not found handler
zinit light Tarrasch/zsh-command-not-found

# Enhanced cd with fuzzy matching
zinit light agkozak/zsh-z

# Colored man pages
zinit light ael-code/zsh-colored-man-pages

# Extract plugin (extract any archive)
zinit light le0me55i/zsh-extract

# Sudo plugin (ESC ESC to add sudo)
zinit light hcgraf/zsh-sudo

# FZF tab completion
zinit light Aloxaf/fzf-tab

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

export EDITOR='nvim'
export VISUAL='nvim'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PAGER='less -R'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# FZF configuration
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS='
  --height 40% --layout=reverse --border=rounded
  --color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284
  --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf
  --color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284
  --prompt="❯ " --pointer="▶" --marker="✓"
  --preview-window=:hidden
  --bind="ctrl-/:toggle-preview"
'

export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always --line-range=:500 {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

export FZF_ALT_C_OPTS="
  --preview 'eza --tree --level=2 --color=always --icons {}'"

# Bat theme
export BAT_THEME="tokyonight_night"

# ============================================================================
# PATH
# ============================================================================

export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/sbin:$PATH"

# Homebrew on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# ============================================================================
# HISTORY
# ============================================================================

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
HISTDUP=erase
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# ============================================================================
# OPTIONS
# ============================================================================

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME
setopt CDABLE_VARS
DIRSTACKSIZE=20

setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt PATH_DIRS
setopt AUTO_MENU
setopt AUTO_LIST
setopt AUTO_PARAM_SLASH
setopt EXTENDED_GLOB
unsetopt MENU_COMPLETE
unsetopt FLOW_CONTROL

setopt CORRECT
setopt CORRECT_ALL

setopt NOTIFY
setopt LONG_LIST_JOBS
setopt CHECK_JOBS
setopt HUP

setopt INTERACTIVE_COMMENTS
setopt MULTIOS
setopt PROMPT_SUBST

# ============================================================================
# COMPLETION SYSTEM
# ============================================================================

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose true
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' squeeze-slashes true

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

zstyle ':completion:*:git-checkout:*' sort false

# FZF-tab configuration
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=2 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --tree --level=2 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza --color=always --icons $realpath'
zstyle ':fzf-tab:complete:nvim:*' fzf-preview 'bat --color=always --line-range=:500 $realpath'
zstyle ':fzf-tab:complete:vim:*' fzf-preview 'bat --color=always --line-range=:500 $realpath'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# ============================================================================
# KEY BINDINGS
# ============================================================================

bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

bindkey '^ ' autosuggest-accept
bindkey '^f' autosuggest-accept

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ============================================================================
# ALIASES
# ============================================================================

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# Directory stack
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# List directory contents
alias ls='eza --color=always --icons --group-directories-first'
alias l='eza -l --color=always --icons --group-directories-first'
alias ll='eza -la --color=always --icons --group-directories-first'
alias la='eza -a --color=always --icons --group-directories-first'
alias lt='eza --tree --level=2 --color=always --icons'
alias tree='eza --tree --color=always --icons'

# File operations
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -pv'

# Git aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gcn!='git commit -v --no-edit --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcan!='git commit -v -a --no-edit --amend'
alias gcam='git commit -a -m'
alias gcb='git checkout -b'
alias gcm='git checkout main || git checkout master'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gfo='git fetch origin'
alias gl='git pull'
alias glg='git log --stat'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glgp='git log --stat -p'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias gm='git merge'
alias gma='git merge --abort'
alias gp='git push'
alias gpd='git push --dry-run'
alias gpf='git push --force-with-lease'
alias gpf!='git push --force'
alias gpoat='git push origin --all && git push origin --tags'
alias gpu='git push upstream'
alias gpv='git push -v'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbd='git rebase develop'
alias grbi='git rebase -i'
alias grbm='git rebase main || git rebase master'
alias grbs='git rebase --skip'
alias grev='git revert'
alias grh='git reset'
alias grhh='git reset --hard'
alias grm='git rm'
alias grmc='git rm --cached'
alias grmv='git remote rename'
alias grrm='git remote remove'
alias grs='git restore'
alias grset='git remote set-url'
alias grss='git restore --staged'
alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'
alias gru='git reset --'
alias grup='git remote update'
alias grv='git remote -v'
alias gs='git status'
alias gsb='git status -sb'
alias gsh='git show'
alias gsi='git submodule init'
alias gsps='git show --pretty=short --show-signature'
alias gss='git status -s'
alias gst='git status'
alias gsta='git stash push'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gstu='git stash --include-untracked'
alias gstall='git stash --all'
alias gsu='git submodule update'
alias gsw='git switch'
alias gswc='git switch -c'
alias gtag='git tag'
alias gts='git tag -s'
alias gtv='git tag | sort -V'
alias gunignore='git update-index --no-assume-unchanged'
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'

# Beautiful git log
alias gll='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# Editor
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nv='nvim'

# System
alias c='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias reload='source ~/.zshrc'
alias zshrc='${EDITOR} ~/.zshrc'

# Network
alias ip='curl -s https://checkip.amazonaws.com'
alias localip='ipconfig getifaddr en0'
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Process management
alias psa='ps aux'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias kill='kill -9'
alias killall='killall -9'

# Disk usage
alias df='df -h'
alias du='du -h'
alias dud='du -d 1 -h'
alias duf='du -sh *'

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
  alias hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
  alias spotlighton='sudo mdutil -a -i on'
  alias spotlightoff='sudo mdutil -a -i off'
  alias o='open .'
  alias flush='dscacheutil -flushcache && killall -HUP mDNSResponder'
  alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
  alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"
fi

# Colored output
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'

# Better commands
alias cat='bat --paging=never'
alias less='bat'
alias find='fd'
alias ps='procs'
alias top='btop'
alias htop='btop'
alias dig='dog'
alias ping='gping'

# Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias drmf='docker rm -f'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'

# Python
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'

# Node.js
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nu='npm uninstall'
alias nug='npm uninstall -g'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'
alias nb='npm run build'
alias nd='npm run dev'

# Yarn
alias y='yarn'
alias ya='yarn add'
alias yad='yarn add --dev'
alias yr='yarn remove'
alias ys='yarn start'
alias yt='yarn test'
alias yb='yarn build'
alias yd='yarn dev'

# Claude CLI alias
alias claude='claude-code'
alias ai='claude-code'

# Quick navigation
alias dev='cd ~/dev'
alias proj='cd ~/projects'
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'
alias dots='cd ~/ide'

# ============================================================================
# FUNCTIONS
# ============================================================================

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Git commit browser
gitlog() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# Search and open file in nvim
fv() {
  local file
  file=$(fzf --preview 'bat --color=always --line-range=:500 {}')
  [ -n "$file" ] && nvim "$file"
}

# Kill process
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}

# Docker container shell
dsh() {
  docker exec -it $(docker ps --format "table {{.Names}}" | sed 1d | fzf) sh
}

# Git branch selector
fbr() {
  local branches branch
  branches=$(git --no-pager branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

# Git checkout with preview
fco() {
  local tags branches target
  tags=$(git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(
    git branch --all | grep -v HEAD |
    sed "s/.* //" | sed "s#remotes/[^/]*/##" |
    sort -u | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
    (echo "$tags"; echo "$branches") |
    fzf --no-hscroll --ansi +m -d "\t" -n 2) || return
  git checkout $(echo "$target" | awk '{print $2}')
}

# Quick backup
backup() {
  cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Weather
weather() {
  curl "wttr.in/${1:-}"
}

# Cheat sheet
cheat() {
  curl "cheat.sh/$1"
}

# ============================================================================
# TOOLS CONFIGURATION
# ============================================================================

# Zoxide (better cd)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# TheFuck (command corrections)
if command -v thefuck &> /dev/null; then
  eval $(thefuck --alias)
  eval $(thefuck --alias fk)
fi

# Direnv
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# iTerm2 Shell Integration
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
  
  # iTerm2 Utilities
  iterm2_print_user_vars() {
    iterm2_set_user_var gitBranch $(git branch --show-current 2>/dev/null || echo "")
    iterm2_set_user_var gitStatus $(git status --porcelain 2>/dev/null | wc -l | xargs)
    iterm2_set_user_var nodeVersion $(node -v 2>/dev/null | sed 's/v//' || echo "")
    iterm2_set_user_var pythonVersion $(python3 --version 2>/dev/null | awk '{print $2}' || echo "")
  }
fi

# ============================================================================
# AUTO-FETCH FOR GIT
# ============================================================================

auto-fetch-git() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    (git fetch --all &) > /dev/null 2>&1
  fi
}
chpwd_functions+=(auto-fetch-git)

# ============================================================================
# AUTO-LS ON CD
# ============================================================================

auto-ls() {
  eza --color=always --icons --group-directories-first
}
chpwd_functions+=(auto-ls)

# ============================================================================
# LOAD OTHER CONFIGURATIONS
# ============================================================================

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Python virtual environment
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
[[ -f /usr/local/bin/virtualenvwrapper.sh ]] && source /usr/local/bin/virtualenvwrapper.sh

# ============================================================================
# DEVELOPMENT TOOLS
# ============================================================================

# Load development helper scripts
DEV_SCRIPTS_DIR="$HOME/ide/dotfiles/scripts/dev"
if [ -d "$DEV_SCRIPTS_DIR" ]; then
  for script in "$DEV_SCRIPTS_DIR"/*.sh; do
    [ -f "$script" ] && source "$script"
  done
fi

# Tmux session management
alias tmux='tmux -f ~/.tmux.conf'
alias ta='tmux attach -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'
alias tks='tmux kill-server'

# Development shortcuts
alias dev='dev_start'
alias devs='dev_stop'
alias test='test_all'
alias check='code_check'
alias build='build_prod'
alias release='release'
alias deploy='deploy'

# Database shortcuts
alias dbc='db_connect'
alias dbb='db_backup'
alias dbm='db_migrate'
alias dbs='db_seed'
alias dbr='db_reset'

# API testing shortcuts  
alias api='api'
alias gql='graphql'
alias jwt='jwt_decode'
alias ws='ws_connect'
alias bench='api_bench'
alias mock='mock_server'

# Project management
alias pnew='project_new'
alias psw='project_switch'
alias pclean='project_clean'
alias pdeps='project_deps'
alias phooks='project_hooks'

# Monitoring shortcuts
alias logs='logs'
alias dlogs='docker_logs'
alias errors='errors'
alias health='health_check'
alias monitor='monitor_dashboard'

# Cloud shortcuts
alias awsp='aws_profile'
alias gcpp='gcp_project'
alias azs='azure_sub'
alias k='kubectl'
alias kctx='k8s_context'
alias kns='k8s_ns'
alias kex='k8s_exec'
alias klog='k8s_logs'
alias kpf='k8s_port_forward'
alias tf='terraform'
alias tfw='tf_workspace'
alias tfp='tf_plan'
alias tfa='tf_apply'

# Quick navigation to development directories
alias dev='cd ~/dev'
alias proj='cd ~/projects'
alias work='cd ~/work'

# ============================================================================
# SSH CONFIGURATION
# ============================================================================

# Load SSH agent configuration
[[ -f ~/.zshrc.ssh ]] && source ~/.zshrc.ssh

# Load local configuration (API keys, etc.)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Load work-specific configurations
[[ -f ~/.zshrc.work ]] && source ~/.zshrc.work

# ============================================================================
# POWERLEVEL10K CONFIGURATION
# ============================================================================

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh