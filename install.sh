#!/usr/bin/env bash
#
# install.sh — symlink dotfiles into place. Safe to re-run.
#
#   ./install.sh            link everything
#   ./install.sh --brew     also run `brew bundle` first
#
# Order: prompt for missing personal values (→ ~/env.zsh), link shell/git/
# config/claude, install Claude plugins, load launchd jobs (assistant jobs only
# when the vault's assistant home exists), macOS defaults.
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

echo "env"
# Personal values the dotfiles read but must never commit. Asked for here and
# written to ~/env.zsh (not linked, not in git). Add one line per new value:
#   NAME|prompt|secret (input hidden), plain, or topic (blank = random)
env_vars=(
  "ASSISTANT_NTFY_TOPIC|ntfy topic for assistant phone pings|topic"
)
env_file="$HOME/env.zsh"
touch "$env_file"
chmod 600 "$env_file"
for entry in "${env_vars[@]}"; do
  IFS='|' read -r name prompt kind <<<"$entry"
  if grep -q "^export $name=" "$env_file"; then
    printf '  ok      %s\n' "$name"
  elif [[ -t 0 ]]; then
    # no empty arrays: macOS bash 3.2 + `set -u` treats them as unbound
    if [[ "$kind" == secret ]]; then
      read -rs -p "  $name: $prompt (blank skips): " value || value=""
      echo
    else
      hint="blank skips"
      [[ "$kind" == topic ]] && hint="blank generates one"
      read -r -p "  $name: $prompt ($hint): " value || value=""
      if [[ -z "$value" && "$kind" == topic ]]; then
        value="assistant-$(openssl rand -hex 12)"
        printf '  topic   %s (subscribe to it in the ntfy app)\n' "$value"
      fi
    fi
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
# agents run it via the allowlist; ~/.local/bin is on PATH even in sessions
# started from a shell older than export.zsh's PATH
link bin/http-status "$HOME/.local/bin/http-status"
# every review skill reads PR feedback through it
link bin/pr-threads "$HOME/.local/bin/pr-threads"
# the only way agents write to GitHub: pending-review comments, never submit
link bin/pr-pending "$HOME/.local/bin/pr-pending"
# start-ticket / deep-review: projects above reviews in herdr's sidebar
link bin/herdr-sort "$HOME/.local/bin/herdr-sort"
# assistant: Basecamp reads + message drafts only (raw basecamp denied)
link bin/basecamp-safe "$HOME/.local/bin/basecamp-safe"
# qa-tester's MCP server launcher (absolute path in agents/qa-tester.md)
link bin/qa-browser "$HOME/.local/bin/qa-browser"
# user-level, not plugin: plugin agents can't declare their own MCP servers
link claude/agents/qa-tester.md "$HOME/.claude/agents/qa-tester.md"
# triage loads only in the assistant home (project skill), not everywhere
if [[ -d "${ASSISTANT_HOME:-$HOME/notes/assistant}" ]]; then
  link claude/assistant/skills/triage "${ASSISTANT_HOME:-$HOME/notes/assistant}/.claude/skills/triage"
  # memory in the synced vault (Obsidian Sync skips dot-folders, so link this)
  link claude/assistant/settings.json "${ASSISTANT_HOME:-$HOME/notes/assistant}/.claude/settings.json"
fi

# Never let claude/git wait on a hidden prompt: no stdin, no git credential
# prompts, 2 min cap per call (perl alarm: macOS has no `timeout`).
cl() { GIT_TERMINAL_PROMPT=0 perl -e 'alarm shift; exec @ARGV' 120 claude "$@" </dev/null; }

if command -v claude >/dev/null; then
  echo "claude plugins"
  if ! cl plugin marketplace list 2>/dev/null | grep -q '❯ dotfiles'; then
    # `marketplace add` rewrites settings.json with an absolute path; keep the
    # portable `~/.dotfiles/claude` by restoring the file afterwards.
    settings="$DOTFILES/claude/settings.json"
    cp "$settings" "$settings.tmp"
    cl plugin marketplace add "$DOTFILES/claude" >/dev/null || printf '  FAILED  marketplace add dotfiles\n'
    mv "$settings.tmp" "$settings"
  fi
  # can't tell what's installed → don't blindly reinstall everything
  if ! installed=$(cl plugin list 2>/dev/null); then
    printf '  FAILED  claude plugin list; skipped installs (run it to see why)\n'
  else
    for p in $(jq -r '.enabledPlugins | keys[]' "$DOTFILES/claude/settings.json"); do
      if grep -q "❯ $p" <<<"$installed"; then
        printf '  ok      %s\n' "$p"
      elif cl plugin install "$p" >/dev/null; then
        printf '  install %s\n' "$p"
      else
        printf '  FAILED  %s (claude plugin install %s)\n' "$p" "$p"
      fi
    done
  fi
fi

if command -v npx >/dev/null; then
  echo "playwright"
  # video recording in the Playwright MCP needs its matching ffmpeg build
  if npx -y -p @playwright/mcp@latest playwright install ffmpeg </dev/null >/dev/null 2>&1; then
    printf '  ok      ffmpeg\n'
  else
    printf '  FAILED  ffmpeg (npx playwright install ffmpeg)\n'
  fi
  echo "skills"
  # upstream plugin.json lists all its skills, so a marketplace entry can't pin a subset
  mp_skills=(grill-me grilling tdd diagnosing-bugs retro writing-for-agents)
  if (cd "$HOME" && npx -y skills@latest add mattpocock/skills -g -a claude-code -s "${mp_skills[@]}" -y </dev/null >/dev/null 2>&1); then
    printf '  ok      mattpocock/skills: %s\n' "${mp_skills[*]}"
  else
    printf '  FAILED  mattpocock/skills (npx skills add mattpocock/skills -g -a claude-code -s %s)\n' "${mp_skills[*]}"
  fi
fi
if [[ -f "$HOME/.cache/qa-tester/profile/.login-stamp" ]]; then
  printf '  ok      qa login profile\n'
else
  printf '  todo    qa login profile (qa-login <url>)\n'
fi

echo "launchd"
# copied, not linked: launchd skips symlinked agents at login
for plist in "$DOTFILES"/launchd/*.plist; do
  label=$(basename "$plist" .plist)
  # assistant jobs need the synced vault; skip on machines without it
  if [[ "$label" == *assistant* && ! -d "${ASSISTANT_HOME:-$HOME/notes/assistant}" ]]; then
    printf '  skip    %s (no ~/notes/assistant; sync the vault, re-run)\n' "$label"
    continue
  fi
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

echo "done. ~/.gitconfig.local (machine-specific git) is yours to create."
