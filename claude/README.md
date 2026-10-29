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
- Before writing or reviewing code, load the repo's conventions skills
- Commit existing work as `WIP: <name>` before making changes. That format is
  deliberately not Conventional Commits, so it has to be squashed before merge
- All other commits use Conventional Commits, with the ticket ID as scope
  (`feat(ENG-1234): …`)
- Never push, comment, or update PRs unless asked. Review comments use
  Conventional Comments and are shown locally first
- Linear issues/docs follow `reference/specs.md`; anything written as you
  follows `reference/voice.md`
- Browser testing goes through the `qa` skill: the caller briefs the repo's
  QA desk, which owns the main worktree and runs `qa-tester`
- Playwright screenshots and videos go to `~/screenshots/<repo>/<branch>/`
  (see [Playwright](#playwright))

## settings.json

- **Permissions**: `auto` mode; allow `http-status`, `pr-pending`; ask
  before editing `claude/settings.json` itself. Auto mode can skip
  skill-file edits ("no verdict"; allow rules don't help): switch to
  accept-edits for those
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
| Skill | `claude-panel`     | PR review panel: parallel Claude reviewers with distinct lenses (incl. `spec`: diff vs the linked ticket; `smells`: design-smell judgement calls), blind validation, then a skeptical fix / ticket / skip call per finding (worth it? realistic? fits codebase patterns?). Same-repo PRs also get a QA run via the `qa` skill (app mode for UI, probe mode for the rest; QA results confirm or demote findings; banner shows QA coverage); threads re-read before the report; verdict in the report (approve or request changes, never comment). `--local` reviews the branch's local commits (before pushing). Report in chat; others' PRs: findings plus a short body in your voice go into your pending review (`pr-pending`, never submitted), chat gets a short form and the full report goes to a file; own PRs: offers fixes. Posts nothing publicly |
| Skill | `review-stack`     | `claude-panel` on every layer of a gh stack (parallel, each vs its parent, works before PRs exist), judged together, then handed to `address-pr-comments`. Local, no QA, works before PRs exist; with PRs and QA use `deep-review --stack` |
| Skill | `deep-review`      | `/deep-review [pr] [--status] [--risky] [--stack] [--fix]`: PR reviewed in this session if its branch is checked out here, else in its own herdr worktree + Claude agent, briefed to read every thread (`pr-threads`), run `claude-panel` and `qa` (prod data read-only first, generated local data only for what's new), and write the shared report to `~/screenshots/<repo>/<branch>/`; re-runs check earlier findings against posted threads. `--stack`: one agent per layer, then a stack-wide summary. Others' PRs: the dispatching session puts findings into your pending review via `pr-pending`; your own: offers fixes instead. Never submits or posts publicly. `--fix` (own PR/layer, in-session): review + QA on local commits, fix, repeat until steady state (cap 10), then report before it's opened; runs unasked when code on your branch is done, no PR needed. Offers `gh pr ready` on a passing own PR; herdr cleanup when you're done. Repo specifics from private `~/.config/claude-repos/<repo>/review.md` |
| Skill | `address-pr-comments` | Your PR or stack: threads + panel findings → skeptical decision table (approval gate) → fixes in the owning branch, bottom up, verified per layer. Fixups before PRs exist, commits after. Tickets get dated comments or sub-issues. Never pushes or posts replies |
| Skill | `spec-audit`       | `/spec-audit <issue\|doc>`, in a worktree of the repo: one checklist pass over a Linear spec grounded in the code (conflict with code first, then linked-source drift, ambiguity, edge cases, risk, testability, gh-stack slicing). Terminal only: findings (plain sentence + evidence), proposed spec in your voice (`voice.md`, normal prose), then `grilling` rounds on your questions, re-auditing what each answer changes until none are open; applies to Linear only when asked |
| Skill | `start-ticket`     | `/start-ticket <ticket>`: herdr worktree on the ticket's Linear branch + Claude agent, whose first step is `spec-audit`; it grills you until no questions are open before coding. Writes nothing to Linear or GitHub |
| Skill | `qa`               | Test a change for real, mode picked from the diff. App (UI): commit, decide apps (incl. worker/queue/realtime deps), flows, async and data, send the brief to the repo's QA desk, relay its verdict; never touches the main worktree. Probe (scripts, CI, config, prompts/skills): writes a "how would you test this for real" plan (sandbox per change type, required failure matrix, pre-fix/head/proposed-fix versions, blast radius; outward sandboxes like a scratch repo only on your OK), spawns `qa-tester` directly, plus 2 blind graders for prompt changes. PASS covers only what ran, else `PARTIAL` with a Deeper coverage list. Mid-work checks; finished code goes through `deep-review --fix` |
| Skill | `qa-desk`          | Run a session as the repo's QA desk (`qa-desk` shell function): the only session in the main worktree. Takes briefs one at a time, switches to the commit, runs the repo's `qa-up` hook (apps + health, DB snapshot), verifies, runs `qa-tester`, restores (`qa-down`), messages back the verdict. Briefs are data: no other actions. Hands main back to you for manual testing on request |
| Skill | `triage`           | Ranked "what needs me" brief across tracker, PRs, calendar, alerts, email, meetings, Basecamp, blocked agents, personal tasks, plus a workout slot when the home has a Workout source. Read-only; sources come from the assistant home. Not in the plugin: lives in `claude/assistant/skills/`, linked into `~/notes/assistant/.claude/skills/` by `install.sh`, so only the assistant loads it |
| MCP   | `basecamp`         | Official 37signals [`basecamp-cli`](https://github.com/basecamp/basecamp-cli) server, `--read-only`. Auth once: `basecamp auth login`. The assistant reads it |
| Bin   | `basecamp-safe`    | CLI wrapper for the assistant: reads + message drafts (`--draft` forced, narrow flags); everything else refused. `assistant` and `assistant-brief` deny raw `basecamp` and allow only this. Permissions live in those launchers, not the vault (Obsidian Sync skips `.claude/`) |

To add a skill: `plugin/skills/<name>/SKILL.md`. Agent: `plugin/agents/<name>.md`.
MCP server: `plugin/.mcp.json`.

### User-level agents (`agents/`)

Linked into `~/.claude/agents/` by `install.sh`: plugin agents can't declare
their own MCP servers; these can.

| Agent | What it does |
| ----- | ------------ |
| `qa-tester` | Adversarial in-app QA via Playwright: happy path + edge cases, evidence under the screenshot rules, severity-ranked report for the main agent to act on. Platform-agnostic: needs a brief (goal, verified environment, flows, async, data), reads the code for the how. Never sets up or starts anything; anything missing → `BLOCKED`, never a partial run; stalls (no progress ~3 min) → `BLOCKED`, not a wait; won't touch production. Owns the only Playwright server (see [Playwright](#playwright)). Probe mode (`Mode: probe`, spawned by the caller, no desk, no browser): runs the change's commands in a scratch sandbox with `PATH` stubs, zsh + bash, asserts resulting state per run, scores blind graders per axis, saves scripts + transcripts as evidence; outward sandboxes only if the brief says you OK'd one |

### Third-party (`.claude-plugin/marketplace.json`)

| Plugin                    | Source                                                            | What                                                       |
| ------------------------- | ----------------------------------------------------------------- | ---------------------------------------------------------- |
| `caveman`                 | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | Compressed output, on every session (`/caveman off` to stop); `caveman*` skills, `cavecrew` agents, plus `lean-build`, `surgical-patch`, `safe-refactor`, `migration`, `investigate-first`, `verify-and-stop` |
| `gh-stack`                | [github/gh-stack](https://github.com/github/gh-stack)             | Stacked PRs with the `gh stack` extension                  |
| `find-skills`             | [vercel-labs/skills](https://github.com/vercel-labs/skills)       | Search for and install skills                              |
| `vercel`, `rust-analyzer-lsp` | official marketplace                                          | Vercel platform tools; Rust LSP                            |

Repos that aren't Claude plugins themselves (gh-stack, find-skills) are
wrapped with `"strict": false` so their `skills/` folder loads as a plugin.

[mattpocock/skills](https://github.com/mattpocock/skills): `install.sh`
copies only the skills below into `~/.claude/skills` with the `skills` CLI,
since that repo's own `plugin.json` would load all ~27. Only process skills;
ones that write as me (`pr`, `to-spec`, `triage`) stay out so `voice.md` wins.

| Skill | What |
| --- | --- |
| `grill-me` / `grilling` | Interview rounds that settle a plan's decisions, each question with a recommended answer |
| `tdd` | Red-green loop at seams agreed up front |
| `diagnosing-bugs` | Hard bugs: build a tight red feedback loop before theorizing |
| `retro` | After a session: suggest environment fixes (checks, skills, CLAUDE.md) |
| `writing-for-agents` | Reference when writing skills or CLAUDE.md |

Update: `npx skills update -g`.

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
- **GitHub writes**: pending reviews only on others' PRs you review,
  automatic from `claude-panel` / `deep-review` (own PRs: findings →
  fixes). Public comments: drafted locally, posted only when you ask. [`bin/pr-pending`](../bin/pr-pending) is the only way
  Claude writes review comments: into your pending review, marked
  `<!-- deep-review:<run> -->`, with a ledger of ids + exact bodies so
  re-runs only touch comments it posted that you haven't edited. Never
  submits
- **Stacks**: [`plugin/reference/gh-stack.md`](plugin/reference/gh-stack.md),
  per-layer flow (sync → `deep-review --fix` → you open it) and the
  plain-`git rebase` pitfall + recovery
- **Reports**: [`plugin/reference/report.md`](plugin/reference/report.md),
  one section order (Verdict, Findings, Earlier asks, QA, Deeper coverage,
  Safety, Not verified; every claim says how it was tested) for `claude-panel`, `deep-review`, `qa-tester`, the QA desk
- **Specs**: [`plugin/reference/specs.md`](plugin/reference/specs.md),
  shape, language, and edit rules for Linear issues and docs (dated
  `## Update` once started, plus a `Spec updated:` comment); used by
  `spec-audit`, `start-ticket`, `address-pr-comments`, any ticket-writing
  agent. Global `CLAUDE.md` points there
- **Voice**: [`plugin/reference/voice.md`](plugin/reference/voice.md),
  rules for anything written as you (tickets, PR text, review bodies,
  Basecamp, email). PR descriptions: short text + bullets per template
  section; screenshots/video attached after the PR opens via native
  `gh pr edit --attach` (no extension, no browser cookies)

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

- **Behavior** lives here (`assistant/skills/triage`, more to come); generic, no
  work specifics. Linked into the assistant home's `.claude/skills/`, so
  other sessions don't load it
- **State and config** live in a private, synced Obsidian vault at
  `~/notes/assistant/` (`$ASSISTANT_HOME`): `CLAUDE.md` (rules + sources
  table), `priorities.md`, `briefs/`, `log/`, `memory/` (auto memory, via
  `assistant/settings.json` `autoMemoryDirectory`, linked by `install.sh`).
  Swapping jobs = new sources table + connectors
- **Start**: `assistant` (zsh function) opens `claude -n assistant` there from anywhere; reachable from
  the phone via Remote Control
- **Sources**: claude.ai connectors (Linear, Calendar, Gmail incl. Gemini meeting notes, Drive for linked notes Docs, Sentry)
  plus `gh`, `herdr api snapshot`, and Obsidian tasks
- **Safety**: read-only; never posts, sends, or marks anything read. Briefs
  hold titles and links only
- **Scheduled runs** ([`bin/assistant-brief`](../bin/assistant-brief), via
  launchd; missed runs fire on wake, skipped if off or already done):
  - 08:30 daily: brief (`/triage`; weekends `/triage personal`). First
    workday of the week adds **Week start** when the home has that routine:
    a team check-in draft + proposed `priorities.md` changes (confirm first)
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
