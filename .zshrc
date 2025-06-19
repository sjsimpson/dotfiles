#!/bin/sh
export PATH=/opt/homebrew/bin:/Users/spencer/.local/bin:/Users/spencer/.cargo/bin:/Users/spencer/.local/bin:/Users/spencer/.local/bin:/Users/spencer/.cargo/bin:/Users/spencer/.local/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Applications/kitty.app/Contents/MacOS

#zap
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

#asdf
# . /opt/homebrew/opt/asdf/libexec/asdf.sh

#mise
eval "$(mise activate zsh)"

#history
HISTFILE=/.zsh_history

# env variables
source "$HOME/env.zsh"

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
# plug "lukechilds/zsh-nvm" --> using asdf now

# Load and initialise completion system
autoload -Uz compinit
compinit
