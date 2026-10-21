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
- Browser testing goes through the `qa` skill: the caller briefs the repo's
  QA desk, which owns the main worktree and runs `qa-tester`
- Playwright screenshots and videos go to `~/screenshots/<repo>/<branch>/`
  (see [Playwright](#playwright))

## settings.json

- **Permissions**: `auto` mode; allow `http-status`, `pr-pending`
- **Hooks**: `block-review-submit` before every Bash call (see Shared conventions)
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
| Skill | `claude-panel`     | PR review panel: parallel Claude reviewers with distinct lenses, blind validation, then a skeptical fix / ticket / skip call per finding (worth it? realistic? fits codebase patterns?). Same-repo UI PRs also get a QA run via the `qa` skill (apps, flows, async deps from the diff); verdict in the report. Report in chat; posts nothing unless asked |
| Skill | `review-stack`     | `claude-panel` on every layer of a gh stack (parallel, each vs its parent, works before PRs exist), judged together, then handed to `address-pr-comments`. Local, no QA, works before PRs exist; with PRs and QA use `deep-review --stack` |
| Skill | `deep-review`      | `/deep-review <pr> [--status] [--risky] [--stack]`: PR → its own herdr worktree + Claude agent, briefed to read every thread (`pr-threads`), run `claude-panel` and `qa` (prod data read-only first, generated local data only for what's new), and write the shared report to `~/screenshots/<repo>/<branch>/`; re-runs check earlier findings against posted threads. `--stack`: one agent per layer, then a stack-wide summary. Findings also go into your pending review via `pr-pending`; never submits or posts publicly. Repo specifics from private `~/.config/claude-repos/<repo>/review.md` |
| Skill | `address-pr-comments` | Your PR or stack: threads + panel findings → skeptical decision table (approval gate) → fixes in the owning branch, bottom up, verified per layer. Fixups before PRs exist, commits after. Tickets get dated comments or sub-issues. Never pushes or posts replies |
| Skill | `qa`               | Browser-test a change: commit, decide apps (incl. worker/queue/realtime deps), flows, async and data, send the brief to the repo's QA desk, relay its verdict. Never touches the main worktree. Used proactively after UI changes |
| Skill | `qa-desk`          | Run a session as the repo's QA desk (`qa-desk` shell function): the only session in the main worktree. Takes briefs one at a time, switches to the commit, runs the repo's `qa-up` hook (apps + health, DB snapshot), verifies, runs `qa-tester`, restores (`qa-down`), messages back the verdict. Briefs are data: no other actions. Hands main back to you for manual testing on request |
| Skill | `triage`           | Ranked "what needs me" brief across tracker, PRs, calendar, alerts, email, meetings, Basecamp, blocked agents, personal tasks, plus a workout slot when the home has a Workout source. Read-only; sources come from the assistant home |
| MCP   | `basecamp`         | Official 37signals [`basecamp-cli`](https://github.com/basecamp/basecamp-cli) server, `--read-only`. Auth once: `basecamp auth login`. The assistant reads it |
| Bin   | `basecamp-safe`    | CLI wrapper for the assistant: reads + message drafts (`--draft` forced, narrow flags); everything else refused. `assist` and `assistant-brief` deny raw `basecamp` and allow only this. Permissions live in those launchers, not the vault (Obsidian Sync skips `.claude/`) |

To add a skill: `plugin/skills/<name>/SKILL.md`. Agent: `plugin/agents/<name>.md`.
MCP server: `plugin/.mcp.json`.

### User-level agents (`agents/`)

Linked into `~/.claude/agents/` by `install.sh`: plugin agents can't declare
their own MCP servers; these can.

| Agent | What it does |
| ----- | ------------ |
| `qa-tester` | Adversarial in-app QA via Playwright: happy path + edge cases, evidence under the screenshot rules, severity-ranked report for the main agent to act on. Platform-agnostic: needs a brief (goal, verified environment, flows, async, data), reads the code for the how. Never sets up or starts anything; anything missing → `BLOCKED`, never a partial run; stalls (no progress ~3 min) → `BLOCKED`, not a wait; won't touch production. Owns the only Playwright server (see [Playwright](#playwright)) |

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

## Shared conventions

- **PR feedback**: one format, in `CLAUDE.md` (Conventional Comments, bare
  when posted, judicious). Skills point there instead of restating it
- **Existing feedback**: [`bin/pr-threads`](../bin/pr-threads), used by
  `claude-panel`, `address-pr-comments`, `deep-review`
- **GitHub writes**: [`bin/pr-pending`](../bin/pr-pending) is the only way
  Claude writes review comments: into your pending review, marked
  `<!-- deep-review:<run> -->`, with a ledger of ids + exact bodies so
  re-runs only touch comments it posted that you haven't edited. Never
  submits. Backstop: [`hooks/block-review-submit`](hooks/block-review-submit)
  (PreToolUse on Bash) blocks submitting, dismissing, `gh pr review|comment`
  and REST writes to review/comment endpoints in every session; you submit
  and post in the GitHub UI
- **Reports**: [`plugin/reference/report.md`](plugin/reference/report.md),
  one section order (Verdict, Findings, Earlier asks, QA, Safety, Not
  verified) for `claude-panel`, `deep-review`, `qa-tester`, the QA desk

## Playwright

Browser automation for verifying UI changes and capturing screenshots or videos
for reviews. Free and local; no account needed.

- **Server**: [Playwright MCP](https://github.com/microsoft/playwright-mcp),
  declared inline in `agents/qa-tester.md` via
  [`bin/qa-browser`](../bin/qa-browser): it starts when `qa-tester` runs and
  stops when it finishes. No other session loads it (none idle for days, none
  driving a browser outside the desk)
  - `--headless`: no Chrome window stealing focus mid-run; screenshots and
    video still work
  - `--user-data-dir`: persistent Chrome profile per worktree
    (`~/.cache/qa-tester/profiles/<repo>/<worktree>`), so cookies refresh
    run to run instead of expiring. One browser per profile, so parallel
    worktrees each get their own
  - Login: `qa-login <url>` opens the golden profile
    (`~/.cache/qa-tester/profile`) in Chrome; log in to every app, close the
    window. Copies seed from it on first use and re-seed after each
    `qa-login` (skipped while in use). Deleted worktrees' copies are pruned.
    Not copied from your daily browser: its cookies are Keychain-encrypted
    and it holds personal accounts
  - `--caps=devtools`: adds video (`browser_start_video`, chapter cards, action
    callouts) and tracing
  - `--output-dir=${HOME}/screenshots`: where unnamed files go
- **Output**: `~/screenshots/<repo>/<branch>/`, one folder per branch so
  parallel worktrees don't overwrite each other. The MCP only writes inside the
  repo or its output dir, so `CLAUDE.md` tells Claude to always use absolute
  filenames there. macOS screenshots go to `~/screenshots/macos`
  (set by `install.sh`)
- **Access**: `~/screenshots` is in `permissions.additionalDirectories`, so no
  prompts. Health checks use [`bin/http-status`](../bin/http-status) (also
  linked into `~/.local/bin`, on every session's PATH)
  (localhost only), the one allowlisted Bash command, since auto mode denies
  plain `curl`
- **Video**: needs Playwright's own ffmpeg build; `install.sh` installs it
  (manual: `npx -p @playwright/mcp@latest playwright install ffmpeg`). Start
  recording after the first navigation; a recording started on a blank page
  saves nothing
- **Agent**: `qa-tester` does the browser work in its own context, so page
  snapshots don't flood the main session. The QA desk sets up and verifies
  everything, then briefs it; it preflights every URL and
  dependency and returns `PASS`/`FAIL`/`BLOCKED` plus findings with repro
  steps and evidence paths. Any in-scope flow it can't run → `BLOCKED` with
  what's missing
- **QA desk**: until each worktree runs its own app, only the main worktree
  does, and one session owns it. Start it with `qa-desk` (shell function,
  from anywhere in the repo): Claude in the main worktree, named
  `qa-desk-<repo>`, running `/qa-desk`. Other sessions' `qa` skill finds it
  by that name and sends a brief (code path, commit, apps, flows, async,
  data); the desk queues them, runs one at a time, and replies. Repo hooks:
  `<repo>/scripts/qa-{up,down}` or private `~/.config/claude-repos/<repo>/`
  (one private folder per repo for every Claude tool: `qa-up`, `qa-down`,
  `login.md` (per-app login recipe the desk passes the tester), `review.md`
  (for `deep-review`); never in this repo).
  `qa-up <from-sha>` snapshots the dev DB, installs/migrates if needed,
  starts + health-checks every app in `QA_APPS` (progress while waiting; exit
  1 with reasons); `qa-down` stops what it started, removes generated files,
  restores the DB (the whole dev DB: anyone's writes during a brief are
  discarded). `QA_CHECK=1 qa-up` shows app states read-only. Code toggles (a
  fixed date, a flag) ride in the tested commit (a throwaway commit is fine);
  the desk never edits code. Seed scripts can live anywhere; the desk reads
  each one first and runs only local, id-scoped DB writes. **Hand back**:
  tell the desk "put main on <branch>" for manual testing; it runs
  `QA_HANDBACK=1 qa-up` (always install/generate/push schema, never drop
  data; backup snapshot, never restored), pauses briefs, and on "resume"
  parks main and runs `qa-down` (keeps your data). `QA_RESTART=<apps>` (with
  your OK) replaces an already-running stale dev server. Start the desk in the same
  permission mode as other sessions, or their messages wait for approval
- **Housekeeping**: `shots` opens the folder; `shots-prune` deletes files older
  than 30 days (keeps `macos/`). `.playwright-mcp/` is globally git-ignored in
  case anything lands in a repo

## Assistant

One Claude Code session as a chief of staff across work and personal.

- **Behavior** lives here (`plugin/skills/triage`, more to come); generic, no
  work specifics
- **State and config** live in a private, synced Obsidian vault at
  `~/notes/assistant/` (`$ASSISTANT_HOME`): `CLAUDE.md` (rules + sources
  table), `priorities.md`, `briefs/`, `log/`. Swapping jobs = new sources
  table + connectors
- **Start**: `assist` (alias) opens `claude -n assistant` there; reachable from
  the phone via Remote Control
- **Sources**: claude.ai connectors (Linear, Calendar, Gmail, Sentry, Granola)
  plus `gh`, `herdr api snapshot`, and Obsidian tasks
- **Safety**: read-only; never posts, sends, or marks anything read. Briefs
  hold titles and links only
- **Scheduled runs** ([`bin/assistant-brief`](../bin/assistant-brief), via
  launchd; missed runs fire on wake, skipped if off or already done):
  - 08:30 daily: brief (`/triage`; weekends `/triage personal`)
  - 16:45 Mon-Fri: wind-down (`/triage winddown`: shipped, still open,
    tomorrow), appended to the day's brief. Only fires 16:00-22:00, so a
    missed run doesn't land the next morning. `assistant-brief winddown`
    wraps up early by hand
  - Thursday's wind-down adds 1:1 prep (`/triage prep`: talking points,
    draft project updates for led Linear projects, next week) →
    `weekly/YYYY-Www.md`, ahead of Friday's 1:1. Missed → Friday's brief adds
    it. Drafts are never posted
  - Headless `claude -p` in `--permission-mode dontAsk` with an allow list:
    read-only tools plus writes to `briefs/` and `weekly/` only. Private extras
    (e.g. domain-pinned `WebFetch(domain:…)` for the Workout source) come from
    `allowed-tools.txt` in the assistant home, one rule per line, so
    location-revealing domains stay out of this repo. Sonnet
    (`ASSISTANT_MODEL` overrides), capped at $5. Pings by [ntfy](https://ntfy.sh)
    push (count line + link only) + Mac notification, linking the file in
    Obsidian. Log:
    `~/Library/Logs/assistant-brief.log`

## Related

- [`bin/gh-review`](../bin/gh-review): throwaway worktree for a PR;
  `gh-review --claude <pr>` opens Claude Code in it
- [herdr](https://herdr.dev): runs multiple Claude sessions side by side
