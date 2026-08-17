#!/bin/sh

export EDITOR="nvim"
export TERMINAL="kitty"
export BROWSER="helium"

export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml


# pnpm config (for work)
export PNPM_HOME="/Users/spencer/Library/pnpm"
# pnpm end

typeset -U path PATH

path=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/.dotfiles/bin"

  # pnpm config (for work)
  $PNPM_HOME

  $path
)

export XDG_CONFIG_HOME="$HOME/.config"

