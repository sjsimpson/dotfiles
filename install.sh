#!/usr/bin/env bash
#
# install.sh — symlink dotfiles into place. Safe to re-run.
#
#   ./install.sh            link everything
#   ./install.sh --brew     also run `brew bundle` first
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

brew=0
for arg in "$@"; do
  case "$arg" in
  --brew) brew=1 ;;
  *)
    echo "unknown flag: $arg" >&2
    exit 1
    ;;
  esac
done

if ((brew)); then
  command -v brew >/dev/null || {
    echo "install Homebrew first: https://brew.sh" >&2
    exit 1
  }
  brew bundle --file "$DOTFILES/Brewfile"
fi

echo "shell + git"
link .zshrc "$HOME/.zshrc"
link git/gitconfig "$HOME/.gitconfig"
link git/ignore "$HOME/.config/git/ignore"

echo "config"
for dir in "$DOTFILES"/config/*/; do
  name=$(basename "$dir")
  # herdr keeps runtime state next to its config, so link just the file
  [[ "$name" == herdr ]] && continue
  link "config/$name" "$HOME/.config/$name"
done
link config/herdr/config.toml "$HOME/.config/herdr/config.toml"
if command -v herdr >/dev/null; then
  for plugin in "$DOTFILES"/config/herdr/plugins/*/; do
    id=$(sed -n 's/^id = "\(.*\)"/\1/p' "$plugin/herdr-plugin.toml")
    if herdr plugin list 2>/dev/null | grep -q "$id"; then
      printf '  ok      herdr plugin %s\n' "$id"
    else
      herdr plugin link "$plugin" >/dev/null && printf '  link    herdr plugin %s\n' "$id"
    fi
  done
fi

# Claude: link files only. Skills and agents load as plugins (see claude/README.md).
echo "claude"
link claude/CLAUDE.md "$HOME/.claude/CLAUDE.md"
link claude/settings.json "$HOME/.claude/settings.json"

if command -v claude >/dev/null; then
  echo "claude plugins"
  if ! claude plugin marketplace list 2>/dev/null | grep -q '❯ dotfiles'; then
    # `marketplace add` rewrites settings.json with an absolute path; keep the
    # portable `~/.dotfiles/claude` by restoring the file afterwards.
    settings="$DOTFILES/claude/settings.json"
    cp "$settings" "$settings.tmp"
    claude plugin marketplace add "$DOTFILES/claude" >/dev/null
    mv "$settings.tmp" "$settings"
  fi
  installed=$(claude plugin list 2>/dev/null)
  for p in $(jq -r '.enabledPlugins | keys[]' "$DOTFILES/claude/settings.json"); do
    if grep -q "❯ $p" <<<"$installed"; then
      printf '  ok      %s\n' "$p"
    else
      claude plugin install "$p" >/dev/null && printf '  install %s\n' "$p"
    fi
  done
fi

echo "macos"
# Native screenshots out of ~/Desktop
shots="$HOME/screenshots/macos"
mkdir -p "$shots"
if [[ "$(defaults read com.apple.screencapture location 2>/dev/null)" != "$shots" ]]; then
  defaults write com.apple.screencapture location "$shots"
  killall SystemUIServer 2>/dev/null || true
fi
printf "  ok      screenshots -> %s\n" "$shots"

echo "done. ~/env.zsh (secrets) and ~/.gitconfig.local (machine-specific git) are yours to create."
