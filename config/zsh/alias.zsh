#!/bin/sh

# general
alias dotfiles="cd ~/.dotfiles && nvim"
alias change="nvim ~/.zshrc"
alias update="source ~/.zshrc"
alias notes="cd ~/.notes && nvim"

# docker
alias dcup="docker compose up -d"
alias dcdown="docker compose down"

# window management
alias wm-start="yabai --start-service"
alias wm-restart="yabai --restart-service"
