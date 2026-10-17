#!/usr/bin/env bash
#
# Herdr event hook. Repos opt in by shipping executable scripts:
#   scripts/wt-setup <worktree-path>     on worktree.created / worktree.opened
#   scripts/wt-teardown <worktree-path>  on worktree.removed
# Repos without them are ignored.
#
# worktree.removed fires after the checkout is gone, so setup records each
# worktree's main checkout and teardown runs from there.

set -euo pipefail

state="${HERDR_PLUGIN_STATE_DIR:?}"
roots="$state/roots"
log="$state/wt-env.log"
mkdir -p "$roots"

# herdr reports names as worktree_created or worktree.created; normalize
event="${HERDR_PLUGIN_EVENT:?}"
event="${event//_/.}"
# last payload, for debugging
printf '%s\n' "${HERDR_PLUGIN_EVENT_JSON:?}" >"$state/last-event.json"
path=$(jq -r '(.data // .).worktree.path // empty' <<<"${HERDR_PLUGIN_EVENT_JSON:?}")
[[ -n "$path" ]] || exit 0

# one state file per worktree, keyed by its path
key=$(printf '%s' "$path" | shasum | cut -c1-16)

notify() {
  "${HERDR_BIN_PATH:-herdr}" notification show "wt-env: $1" --body "$path" --sound request >/dev/null 2>&1 || true
}

run() { # script, cwd
  printf '%s %s %s\n' "$(date '+%F %T')" "$1" "$path" >>"$log"
  if ! (cd "$2" && "$1" "$path") >>"$log" 2>&1; then
    notify "$(basename "$1") failed (see $log)"
    exit 1
  fi
}

case "$event" in
worktree.created | worktree.opened)
  setup="$path/scripts/wt-setup"
  [[ -x "$setup" ]] || exit 0
  common=$(git -C "$path" rev-parse --path-format=absolute --git-common-dir)
  dirname "$common" >"$roots/$key"
  run "$setup" "$path"
  ;;
worktree.removed)
  [[ -f "$roots/$key" ]] || exit 0
  root=$(<"$roots/$key")
  teardown="$root/scripts/wt-teardown"
  [[ -x "$teardown" ]] && run "$teardown" "$root"
  rm -f "$roots/$key"
  ;;
esac
