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

if command -v npx >/dev/null; then
  echo "playwright"
  # video recording in the Playwright MCP needs its matching ffmpeg build
  if npx -y -p @playwright/mcp@latest playwright install ffmpeg >/dev/null 2>&1; then
    printf '  ok      ffmpeg\n'
  else
    printf '  FAILED  ffmpeg (npx playwright install ffmpeg)\n'
  fi
fi

echo "launchd"
# copied, not linked: launchd skips symlinked agents at login
for plist in "$DOTFILES"/launchd/*.plist; do
  label=$(basename "$plist" .plist)
  dst="$HOME/Library/LaunchAgents/$label.plist"
  if cmp -s "$plist" "$dst"; then
    printf '  ok      %s\n' "$label"
    continue
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$plist" "$dst"
  launchctl bootout "gui/$UID/$label" 2>/dev/null || true
  launchctl bootstrap "gui/$UID" "$dst" && printf '  load    %s\n' "$label"
done

echo "macos"
# Native screenshots out of ~/Desktop
shots="$HOME/screenshots/macos"
mkdir -p "$shots"
if [[ "$(defaults read com.apple.screencapture location 2>/dev/null)" != "$shots" ]]; then
  defaults write com.apple.screencapture location "$shots"
  killall SystemUIServer 2>/dev/null || true
fi
printf "  ok      screenshots -> %s\n" "$shots"

echo "env"
# Personal values the dotfiles read but must never commit. Asked for here and
# written to ~/env.zsh (not linked, not in git). Add one line per new value:
#   NAME|prompt|secret (input hidden) or plain
env_vars=(
  "ASSISTANT_IMESSAGE_TO|iMessage address for assistant-brief pings (phone or Apple ID email)|plain"
)
env_file="$HOME/env.zsh"
touch "$env_file"
chmod 600 "$env_file"
for entry in "${env_vars[@]}"; do
  IFS='|' read -r name prompt kind <<<"$entry"
  if grep -q "^export $name=" "$env_file"; then
    printf '  ok      %s\n' "$name"
  elif [[ -t 0 ]]; then
    flag=()
    [[ "$kind" == secret ]] && flag=(-s)
    read -r "${flag[@]}" -p "  $name: $prompt (blank skips): " value
    [[ "$kind" == secret ]] && echo
    if [[ -n "$value" ]]; then
      printf 'export %s=%q\n' "$name" "$value" >>"$env_file"
      printf '  set     %s\n' "$name"
    else
      printf '  skip    %s\n' "$name"
    fi
  else
    printf '  missing %s (re-run ./install.sh in a terminal)\n' "$name"
  fi
done

echo "done. ~/.gitconfig.local (machine-specific git) is yours to create."
