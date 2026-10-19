# Claude Code

My [Claude Code](https://claude.com/claude-code) config.

| Path                            | How it's loaded                                  | What                                     |
| ------------------------------- | ------------------------------------------------ | ---------------------------------------- |
| `CLAUDE.md`                     | linked to `~/.claude/CLAUDE.md`                  | Global instructions for every session    |
| `settings.json`                 | linked to `~/.claude/settings.json`              | Hooks, permissions, plugins, attribution |
| `plugin/`                       | live via `CLAUDE_CODE_PLUGIN_DIRS`               | My skills, agents, and MCP servers (plugin `sjsimpson`) |
| `.claude-plugin/marketplace.json` | local marketplace `dotfiles` (`extraKnownMarketplaces`) | Third-party plugins I use          |

`settings.json` is the source of truth for what's installed: `enabledPlugins`
lists every plugin, and `install.sh` installs any that are missing.

## CLAUDE.md

Global rules, in short:

- Be terse, including in commits and plans
- Plans end with a list of open questions
- Commit existing work as `WIP: <name>` before making changes. That format is
  deliberately not Conventional Commits, so it has to be squashed before merge
- All other commits use Conventional Commits, with the ticket ID as scope
  (`feat(ENG-1234): …`)
- Never push, comment, or update PRs unless asked. Review comments use
  Conventional Comments and are shown locally first
- Playwright screenshots and videos go to `~/screenshots/<repo>/<branch>/`
  (see [Playwright](#playwright))

## settings.json

- **Permissions**: `auto` mode
- **Attribution**: off for commits and PRs (no `Co-Authored-By` or session links)
- **Env**: `CLAUDE_CODE_PLUGIN_DIRS` loads `plugin/` and moshi straight from disk
- **Marketplace path**: `~/.dotfiles/claude`, kept portable. `claude plugin
  marketplace add` rewrites it to an absolute path, so `install.sh` restores
  the file afterwards
- **Hooks**:
  - Notification: macOS notification via `terminal-notifier`, only when the
    kitty window running Claude isn't focused (needs `jq`)
  - Session, prompt, and tool events: forwarded to
    [moshi](https://github.com/rjyo/moshi) (`moshi-hook`) for remote sessions

## Plugins

### Mine: `sjsimpson` (`plugin/`)

Loaded live from the folder, so edits apply on the next session with no
reinstall. Invoke as `/claude-panel` (or `/sjsimpson:claude-panel` if a name
ever clashes).

| Kind  | Name               | What                                                                    |
| ----- | ------------------ | ----------------------------------------------------------------------- |
| Skill | `claude-panel`     | PR review panel: parallel Claude reviewers with distinct lenses, blind validation, report in chat. Posts nothing unless asked |
| Agent | `qa-tester`        | Adversarial in-app QA via Playwright: happy path + edge cases, evidence under the screenshot rules, severity-ranked report for the main agent to act on. Read-only on code; won't start servers or touch production |
| MCP   | `playwright`       | Browser automation. `--isolated` so parallel sessions don't share a profile; `--caps=devtools` adds video and tracing; output to `~/screenshots` |

To add a skill: `plugin/skills/<name>/SKILL.md`. Agent: `plugin/agents/<name>.md`.
MCP server: `plugin/.mcp.json`.

### Third-party (`.claude-plugin/marketplace.json`)

| Plugin                    | Source                                                            | What                                                       |
| ------------------------- | ----------------------------------------------------------------- | ---------------------------------------------------------- |
| `caveman`                 | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | Compressed output, on every session (`/caveman off` to stop); `caveman*` skills, `cavecrew` agents, plus `lean-build`, `surgical-patch`, `safe-refactor`, `migration`, `investigate-first`, `verify-and-stop` |
| `gh-stack`                | [github/gh-stack](https://github.com/github/gh-stack)             | Stacked PRs with the `gh stack` extension                  |
| `find-skills`             | [vercel-labs/skills](https://github.com/vercel-labs/skills)       | Search for and install skills                              |
| `vercel`, `rust-analyzer-lsp` | official marketplace                                          | Vercel platform tools; Rust LSP                            |

Repos that aren't Claude plugins themselves (gh-stack, find-skills) are
wrapped with `"strict": false` so their `skills/` folder loads as a plugin.

To add one:

1. Add an entry to `.claude-plugin/marketplace.json` (or use an existing marketplace)
2. Add `"<name>@dotfiles": true` to `enabledPlugins` in `settings.json`
3. Run `claude plugin marketplace update dotfiles && ./install.sh`
4. Add a row to the table above

`claude plugin details <name>@<marketplace>` shows what a plugin loads (skills,
agents, hooks) and its token cost.

## Playwright

Browser automation for verifying UI changes and capturing screenshots or videos
for reviews. Free and local; no account needed.

- **Server**: [Playwright MCP](https://github.com/microsoft/playwright-mcp),
  shipped in `plugin/.mcp.json`, so every machine gets the same config
  - `--isolated`: browser profile in memory, so parallel sessions don't fight
    over one profile. Each session starts logged out; for authed apps, pass
    `--storage-state <file>` with a saved login
  - `--caps=devtools`: adds video (`browser_start_video`, chapter cards, action
    callouts) and tracing
  - `--output-dir=${HOME}/screenshots`: where unnamed files go
- **Output**: `~/screenshots/<repo>/<branch>/`, one folder per branch so
  parallel worktrees don't overwrite each other. The MCP only writes inside the
  repo or its output dir, so `CLAUDE.md` tells Claude to always use absolute
  filenames there. macOS screenshots go to `~/screenshots/macos`
  (set by `install.sh`)
- **Access**: `~/screenshots` is in `permissions.additionalDirectories`, so no
  prompts
- **Video**: needs Playwright's own ffmpeg build; `install.sh` installs it
  (manual: `npx -p @playwright/mcp@latest playwright install ffmpeg`). Start
  recording after the first navigation; a recording started on a blank page
  saves nothing
- **Agent**: `qa-tester` does the browser work in its own context, so page
  snapshots don't flood the main session. Ask the main session to "use
  qa-tester on <flow> at <url>"; it returns `PASS`/`FAIL`/`BLOCKED` plus
  findings with repro steps and evidence paths
- **Housekeeping**: `shots` opens the folder; `shots-prune` deletes files older
  than 30 days (keeps `macos/`). `.playwright-mcp/` is globally git-ignored in
  case anything lands in a repo

## Related

- [`bin/gh-review`](../bin/gh-review): throwaway worktree for a PR;
  `gh-review --claude <pr>` opens Claude Code in it
- [herdr](https://herdr.dev): runs multiple Claude sessions side by side
