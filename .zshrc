#!/bin/sh

#homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

#zap
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

#asdf
# . /opt/homebrew/opt/asdf/libexec/asdf.sh

#mise
eval "$(mise activate zsh)"

# env variables, should never be committed
[ -f "$HOME/env.zsh" ] && source "$HOME/env.zsh"

# source
plug "$HOME/.config/zsh/alias.zsh"
plug "$HOME/.config/zsh/export.zsh"
plug "$HOME/.config/zsh/starship.zsh"
# TODO: Add `dev` script for opening TMUX with all configured windows

# plugins
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-completions"
plug "zap-zsh/supercharge"
plug "zap-zsh/exa"
# plug "lukechilds/zsh-nvm" --> using `asdf` now --> using `mise` now (see 11)

