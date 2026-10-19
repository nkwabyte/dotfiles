# ==============================================================================
# Zsh Configuration
# Portable, fast, and keyboard-centric configuration
# ==============================================================================

# Prompt substitution & completion matching
setopt prompt_subst
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Completions directories
[ -d "$HOME/.docker/completions" ] && fpath=("$HOME/.docker/completions" $fpath)
[ -d "$HOME/.grok/completions/zsh" ] && fpath=("$HOME/.grok/completions/zsh" $fpath)

autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit

# Tool completions
command -v kubectl &>/dev/null && source <(kubectl completion zsh 2>/dev/null)
[ -x '/usr/local/bin/aws_completer' ] && complete -C '/usr/local/bin/aws_completer' aws

# Autosuggestions (Homebrew location)
if [ -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f "$(brew --prefix 2>/dev/null)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

bindkey '^w' autosuggest-execute
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search

# Vi Mode
bindkey jj vi-cmd-mode

# Fast Node Manager (fnm)
command -v fnm &>/dev/null && eval "$(fnm env --use-on-cd --shell zsh)"

# Starship Prompt
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
command -v starship &>/dev/null && eval "$(starship init zsh)"

# Environment variables
export LANG=en_US.UTF-8
export EDITOR="$(command -v nvim || command -v vim || echo 'nano')"
export GOPATH="$HOME/go"
export XDG_CONFIG_HOME="$HOME/.config"
export KUBECONFIG=~/.kube/config

# PATH setup
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.local/bin:$HOME/.cargo/bin:$GOPATH/bin:$HOME/.antigravity-ide/antigravity-ide/bin:$HOME/.lmstudio/bin:$HOME/.grok/bin:/opt/homebrew/opt/libpq/bin:$PATH"

# Nix support if installed
export NIX_CONF_DIR="$HOME/.config/nix"
[ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ] && . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
[ -d "/run/current-system/sw/bin" ] && export PATH="/run/current-system/sw/bin:$PATH"

# ==============================================================================
# Aliases
# ==============================================================================

# Core utilities
alias cl='clear'
alias cat='bat'
alias la='tree'
alias http='xh'
alias v='nvim'

# Modern file listing with eza / ls
if command -v eza &>/dev/null; then
    alias l="eza -l --icons --git -a"
    alias lt="eza --tree --level=2 --long --icons --git"
    alias ltree="eza --tree --level=2 --icons --git"
    alias ll="eza -lah --icons"
else
    alias l="ls -la"
    alias ll="ls -lah"
fi

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

cx() { cd "$@" && l; }
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy; }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)"; }

# Git
alias gs="git status"
alias gst="git status"
alias ga="git add"
alias gadd="git add"
alias gap="git add -p"
alias gc="git commit"
alias gcm="git commit -m"
alias gca="git commit -a -m"
alias gp="git push"
alias gpo="git push origin HEAD"
alias gpu="git pull origin"
alias gl="git log --oneline --graph --decorate"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb="git branch"
alias gba="git branch -a"
alias gr="git remote"
alias gre="git reset"
alias gcoall="git checkout -- ."

# Docker
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"

# Kubernetes
alias k="kubectl"
alias ka="kubectl apply -f"
alias kg="kubectl get"
alias kd="kubectl describe"
alias kdel="kubectl delete"
alias kl="kubectl logs -f"
alias ke="kubectl exec -it"
alias kgpo="kubectl get pod"
alias kgd="kubectl get deployments"
alias kc="kubectx"
alias kns="kubens"
alias kcns='kubectl config set-context --current --namespace'

# Security & Network
alias nm="nmap -sC -sV -oN nmap"
alias server='python3 -m http.server 4445'
alias tunnel='ngrok http 4445'

# ==============================================================================
# Development Toolchains
# ==============================================================================

# C++ LLVM Toolchain (Apple Silicon / Homebrew)
export LLVM_DIR="/opt/homebrew/opt/llvm"
alias llvm++="$LLVM_DIR/bin/clang++"
alias cppd='clang++ -std=c++20 -g -O0 -Wall -Wextra -Wpedantic -Wshadow -Wconversion -fsanitize=address,undefined -fno-omit-frame-pointer'
alias cppd-llvm="$LLVM_DIR/bin/clang++ -std=c++20 -g -O0 -Wall -Wextra -Wpedantic -Wshadow -Wconversion -fsanitize=address,undefined -fno-omit-frame-pointer -L$LLVM_DIR/lib/c++ -Wl,-rpath,$LLVM_DIR/lib/c++"
alias cppt='clang++ -std=c++20 -g -O1 -Wall -Wextra -fsanitize=thread'
alias cppt-llvm="$LLVM_DIR/bin/clang++ -std=c++20 -g -O1 -Wall -Wextra -fsanitize=thread"
alias cppr='clang++ -std=c++20 -O2 -DNDEBUG -Wall -Wextra'
alias clang-tidy="$LLVM_DIR/bin/clang-tidy"
alias clang-format="$LLVM_DIR/bin/clang-format"
leakcheck() { leaks --atExit -- "$@"; }

# ==============================================================================
# Integrations & Plugins
# ==============================================================================

# FZF
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Shell Integrations
[ -f "${HOME}/.iterm2_shell_integration.zsh" ] && source "${HOME}/.iterm2_shell_integration.zsh"
[ -f "${HOME}/.jetbrains.vmoptions.sh" ] && . "${HOME}/.jetbrains.vmoptions.sh"

command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v atuin &>/dev/null && eval "$(atuin init zsh)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# ==============================================================================
# Machine-specific Local Overrides
# ==============================================================================
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
