#!/usr/bin/env bash
#
# install.sh — symlink dotfiles into place. Safe to re-run.
#
#   ./install.sh          link everything
#   ./install.sh --brew   also run `brew bundle` first
#
# Existing files are moved to <name>.bak before linking.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$DOTFILES/$1" dst="$2"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    printf '  ok      %s\n' "$dst"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    mv "$dst" "$dst.bak"
    printf '  backup  %s.bak\n' "$dst"
  fi
  ln -s "$src" "$dst"
  printf '  link    %s\n' "$dst"
}

if [[ "${1:-}" == "--brew" ]]; then
  command -v brew >/dev/null || {
    echo "install Homebrew first: https://brew.sh" >&2
    exit 1
  }
  brew bundle --file "$DOTFILES/Brewfile"
fi

echo "shell + git"
link .zshrc "$HOME/.zshrc"
link tmux/tmux.conf "$HOME/.tmux.conf"
link git/gitconfig "$HOME/.gitconfig"
link git/ignore "$HOME/.config/git/ignore"

echo "config"
for dir in "$DOTFILES"/config/*/; do
  name=$(basename "$dir")
  link "config/$name" "$HOME/.config/$name"
done

# Claude: link individual files, never whole dirs — ~/.claude/{skills,agents}
# also hold things installed by other tools.
echo "claude"
link claude/CLAUDE.md "$HOME/.claude/CLAUDE.md"
link claude/settings.json "$HOME/.claude/settings.json"
for f in "$DOTFILES"/claude/agents/*.md; do
  link "claude/agents/$(basename "$f")" "$HOME/.claude/agents/$(basename "$f")"
done
for d in "$DOTFILES"/claude/skills/*/; do
  name=$(basename "$d")
  link "claude/skills/$name" "$HOME/.claude/skills/$name"
done

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  echo "tmux plugin manager"
  git clone --quiet https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

echo "done. ~/env.zsh (secrets) and ~/.gitconfig.local (machine-specific git) are yours to create."
