---
name: qa
description: Test a change in the running app through a real browser, via the repo's QA desk. Commit, decide what the test needs, send the desk a brief, then relay its verdict. Use proactively after any UI change, before reporting it done, or when the user asks to QA / browser-test something.
argument-hint: "[what to test] (optional; defaults to the current change)"
---

# QA

The main worktree runs the app and belongs to the repo's QA desk, a separate
session (`/qa-desk`). The desk switches it to your commit, starts and checks
the apps, prepares data, runs `qa-tester`, restores everything, and messages
you the verdict. Your job: say exactly what to test and what it needs. Never
switch, edit, or start anything in the main worktree yourself.

## 1. Commit

The desk tests a commit, so commit first (WIP is fine).

## 2. Decide what the test needs

From the change and the code:

- **Apps**: every app the flows touch, plus their runtime dependencies: API,
  background workers, queues, schedulers, realtime/websocket servers. An
  async flow without its worker can't be tested
- **Flows**: the user-facing flows to exercise, happy path first
- **Async**: how background work gets triggered, and the states to watch
  (e.g. queued → done | failed)
- **Data**: the records/accounts/states needed, and how to create them. A
  seed script must be committed (a throwaway commit is fine) so the desk runs
  it from the tested commit; give the exact command. Using an env var in
  the command's own arguments needs `export X=…; cmd $X/…`: in `X=… cmd
  $X/…` (or `env X=…`), `$X` expands before the assignment applies
- **Code toggles** (a fixed "today" date, a feature flag in code): never ask
  the desk to edit code. Put them on a throwaway commit on top of your
  change and brief that commit's sha

## 3. Find the desk

Repo name = the main worktree's directory name
(`basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"`).
`ListAgents` should show `qa-desk-<repo>`. Not listed → stop and tell the
user: "Start the QA desk: run `qa-desk` in a terminal in `<repo>`." Don't
test any other way.

## 4. Send the brief

`SendMessage` to `qa-desk-<repo>`:

```
QA brief
From: <this session's name>
Code: <absolute path of this worktree>
Commit: <full sha of HEAD>
Base: <base ref for the diff, e.g. origin/main>
Apps: <a,b,c>
Goal: <what changed and what it's for, 1-3 lines>
Flows: <...>
Async: <how to trigger; states to watch>
Data: <what must exist, how to create it>
Login: <saved session, or test credentials>
Out of scope: <anything deliberately not tested>
```

Every field that applies is required. The desk replies `incomplete brief`
otherwise, and the tester blocks rather than test partially. The tester
works out the steps, selectors, and edge cases from the code.

## 5. Wait and report

Don't poll; the desk's reply wakes you ("queued (N ahead)" first if it's
busy). Report the verdict, findings, and "Not tested". `BLOCKED` is never a
pass. If it's blocked on something you can fix (code, a better brief),
fix it, commit, and send a new brief.
