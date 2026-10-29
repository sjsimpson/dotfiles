---
name: qa
description: "Test a change for real: app mode (browser, via the repo's QA desk) for UI, probe mode (the change's commands run in a sandbox, failure matrix, blind graders) for everything else. Use for a mid-work check, when deep-review/claude-panel call it, or when the user asks to QA / test something. Finished code → `/deep-review --fix` instead."
argument-hint: "[what to test] (optional; defaults to the current change)"
---

# QA

## 0. Pick the mode

From the diff (`git diff --name-only <base>...HEAD`):

- **App**: the change shows up in the running app (components, styles,
  routes, server actions, jobs a UI flow triggers). Steps 1-5
- **Probe**: everything else: scripts, CLIs, CI workflows, config,
  prompts/rubrics/skills, libraries without a UI. Probe mode below
- Both apply → run both; each gets its own QA verdict
- Docs-only prose → no QA; say so and why

PASS covers only what ran. Fewer scenarios than planned → `PARTIAL`, never
PASS. Report per `report.md` (plugin `reference/`).

## App mode

The main worktree runs the app and belongs to the repo's QA desk, a separate
session (`/qa-desk`). The desk switches it to your commit, starts and checks
the apps, prepares data, runs `qa-tester`, restores everything, and messages
you the verdict. Your job: say exactly what to test and what it needs. Never
switch, edit, or start anything in the main worktree yourself.

### 1. Commit

The desk tests a commit, so commit first (WIP is fine).

### 2. Decide what the test needs

From the change and the code:

- **Apps**: every app the flows touch, plus their runtime dependencies: API,
  background workers, queues, schedulers, realtime/websocket servers. An
  async flow without its worker can't be tested
- **Flows**: the user-facing flows to exercise, happy path first
- **Async**: how background work gets triggered, and the states to watch
  (e.g. queued → done | failed)
- **Data**: the records/accounts/states needed, and how to create them. A
  seed script can live anywhere (your scratchpad is fine); give its absolute
  path and the exact command. The desk reads it first and runs it only if it
  sticks to id-scoped local dev DB writes. Using an env var in
  the command's own arguments needs `export X=…; cmd $X/…`: in `X=… cmd
  $X/…` (or `env X=…`), `$X` expands before the assignment applies
- **Code toggles** (a fixed "today" date, a feature flag in code): never ask
  the desk to edit code. Put them on a throwaway commit on top of your
  change and brief that commit's sha

### 3. Find the desk

Repo name = the main worktree's directory name
(`basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"`).
`ListAgents` should show `qa-desk-<repo>`. Not listed → stop and tell the
user: "Start the QA desk: run `qa-desk` in a terminal in `<repo>`." Don't
test any other way.

### 4. Send the brief

`SendMessage` to `qa-desk-<repo>`:

```
QA brief
From: <this session's name>
Mode: app
Code: <absolute path of this worktree>
Commit: <full sha of HEAD>
Base: <base ref for the diff, e.g. origin/main>
Apps: <a,b,c>
Goal: <what changed and what it's for, 1-3 lines>
Flows: <...>
Async: <how to trigger; states to watch>
Data: <what must exist, how to create it>
Login: <saved session, or test credentials>
Evidence: <dir the caller wants evidence in; default $HOME/screenshots/<repo>/<this worktree's branch, / → ->/>
Out of scope: <anything deliberately not tested>
```

Every field that applies is required. The desk replies `incomplete brief`
otherwise, and the tester blocks rather than test partially. The tester
works out the steps, selectors, and edge cases from the code.

### 5. Wait and report

Don't poll; the desk's reply wakes you ("queued (N ahead)" first if it's
busy). Report the verdict, findings, and "Not verified". `BLOCKED` is never a
pass. If it's blocked on something you can fix (code, a better brief),
fix it, commit, and send a new brief.

## Probe mode

No browser, no desk: runs from this worktree (or the caller's review
worktree), so nothing queues. Bar: run the real commands, try to break
them, back every claim with a run.

### P1. Plan: how would you test this for real?

Write the probe plan from the diff, the intent, and the code:

- **Change type → sandbox**:
  - Script/CLI: the exact commands from the change with the real tools,
    plus `PATH` shims for failures (`jq` exiting 127, a `gh` wrapper that
    fails only GET or only POST). zsh and bash. Check state the change must
    leave alone (e.g. unrelated labels). Runs are cheap: plan dozens
  - Outward-facing (GitHub writes, CI, a real external API): never pick
    the sandbox alone. Ask the user first (AskUserQuestion, e.g. private
    scratch repo vs stubbed `gh`). Can't ask (a herdr agent) → message the
    parent session, run the stubbed scenarios meanwhile; no answer → those
    scenarios are `skipped` and the verdict is at best `PARTIAL`
  - HTTP/external API: a local fake server or recorded fixtures
  - Prompt/rubric/skill: 2 blind graders given only the artifact, on a
    fixed sample of ≥5 real inputs, plus rule-conflict cases from real
    data and 1 planted injection in an input they read. Agreement per axis,
    never only the total (8/8, 8/8, 4/8 hides behind 20/24)
  - Disputed fact ("does POST auto-create?"): a scenario that tests it.
    Never settle it by reasoning
- **Failure matrix** (required): invalid enum/off-list value, missing
  dependency, partial API failure mid-run (each call, e.g. POST after
  DELETE), re-run idempotency (same input, new input), shell differences.
  Each run asserts the resulting state, not the exit code
- **Versions**: pre-fix (`git show <sha>^:<file>`; proves the matrix
  catches the bug), head, every proposed fix (reviewers' and ours)
- **Blast radius**: what reads or triggers on the changed files (build, CI
  workflows, label/webhook triggers)
- **Out of reach**: what this sandbox can't cover, and what would

### P2. Run

Spawn `qa-tester` directly (Agent tool, no desk) with:

```
QA brief
Mode: probe
From: <this session's name>
Code: <absolute path of the worktree at the commit>
Commit: <full sha>
Base: <base ref>
Goal: <what changed and what it's for, 1-3 lines>
Plan: <P1, in full>
Sandbox: <scratch dir / fake server / the scratch repo the user OK'd, or "stubs only">
Graders: <dir with the 2 graders' outputs, or "none">
Evidence: <dir; default $HOME/screenshots/<repo>/<branch, / → ->/>
```

Graders first, when the plan has them: spawn 2 agents in parallel, each
given only the artifact and the sample, no rubric hints or each other's
output; save each output to the Graders dir.

### P3. Report and teardown

Relay qa-tester's report (verdict, coverage, scenario table, Deeper
coverage). List every sandbox still live; deleting an outward one (e.g. a
scratch repo) asks the user first.
