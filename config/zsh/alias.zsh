#!/bin/sh

# general
alias dotfiles="cd ~/.dotfiles && nvim"
alias change="nvim ~/.zshrc"
alias update="source ~/.zshrc"
alias notes="cd ~/notes && nvim"
alias assist="cd ~/notes/assistant && claude -n assistant"

# docker
alias dcup="docker compose up -d"
alias dcdown="docker compose down"

# window management
alias wm-start="yabai --start-service"
alias wm-restart="yabai --restart-service"

# lazygit
alias lg="lazygit"

# screenshots (macOS + Playwright); prune keeps macOS ones
alias shots="open ~/screenshots"
alias shots-prune="find ~/screenshots -type f -mtime +30 -not -path '*/macos/*' -print -delete"
