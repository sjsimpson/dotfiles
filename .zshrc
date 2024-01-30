#!/bin/sh
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

#history
HISTFILE=/.zsh_history

# source
plug "$HOME/.config/zsh/alias.zsh"
plug "$HOME/.config/zsh/export.zsh"
plug "$HOME/.config/zsh/starship.zsh"

# plugins
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-completions"
plug "zap-zsh/supercharge"
plug "zap-zsh/exa"
plug "lukechilds/zsh-nvm"

# Load and initialise completion system
autoload -Uz compinit
compinit
