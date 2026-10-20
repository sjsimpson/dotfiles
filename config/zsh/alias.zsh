#!/bin/sh

# general
alias dotfiles="cd ~/.dotfiles && nvim"
alias change="nvim ~/.zshrc"
alias update="source ~/.zshrc"
alias notes="cd ~/notes && nvim"
alias assist="cd ~/notes/assistant && claude -n assistant"
# QA desk: from anywhere in a repo, open Claude in its main worktree as
# qa-desk-<repo>, the session other agents send QA briefs to
qa-desk() {
  local common
  common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) ||
    { echo "qa-desk: not in a git repo" >&2; return 1; }
  cd "${common:h}" && claude -n "qa-desk-${common:h:t}" "/qa-desk"
}

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
