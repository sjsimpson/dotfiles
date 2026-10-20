---
name: qa
description: Test a change in the running app through a real browser. The calling session prepares the environment (lease, apps, data), briefs the qa-tester agent, and cleans up. Use proactively after any UI change, before reporting it done, or when the user asks to QA / browser-test something.
argument-hint: "[what to test] (optional; defaults to the current change)"
---

# QA

You own the environment; `qa-tester` owns the testing. You know the repo, its
apps, its data, and what the change is for, so you get everything running and
verified before the tester starts. The tester reads the code to decide how to
test, but it never sets anything up. A run either has everything it needs or
it doesn't start: no partial runs.

## 1. Commit

The change under test must be committed (WIP is fine): `qa-lease` and the
tester both work from HEAD.

## 2. Decide what the test needs

From the change and the code, write down:

- **Apps**: every app the flows touch, plus their runtime dependencies: API,
  background workers, queues, schedulers, realtime/websocket servers, local
  emulators. An async flow without its worker can't be tested
- **Data**: the records/accounts/states the flows need, and how to create
  them (UI, seed script, fixture)
- **Async**: how background work gets triggered, and how to see it finish

## 3. Prepare the environment

**Repo has `qa-lease` hooks** (`<repo>/scripts/qa-up`, or
`~/.config/qa-lease/<repo>/qa-up`): from the worktree under test, run bare
(no pipes; Bash timeout 600000):

```
qa-lease acquire --apps <a,b,...>
```

- Last line `qa-lease: READY` → continue
- `NOT READY` (exit 5; lease already released): read the reasons. Fix what
  you can (a stale process on a port, a missing seed, a down container) and
  acquire again. Otherwise stop and tell the user exactly what's missing.
  Don't brief the tester
- Exit 3: commit first. 75 / 4: another run holds it or the main worktree is
  busy; say who, and retry or stop

**No hooks**: the app is whatever is already running. Check each app and
dependency yourself (step 4). If something isn't running, start it only if
the repo documents how and the user is fine with it; otherwise stop.

## 4. Verify before briefing

Every URL and dependency in the brief must answer now: `curl` each app's URL
and each worker/queue health or status endpoint the repo has. Seed the data.
Anything that doesn't check out → fix it or stop. Never send the tester into
an environment you haven't verified.

## 5. Brief `qa-tester`

Spawn the `qa-tester` agent from the worktree under test, with:

```
Goal: <what changed and what it's for, 1-3 lines>
Base: <base ref for the diff, e.g. origin/main>
Environment (verified ready):
- <app>: <url>
- <dependency>: <how it's reached / health check> (e.g. worker, queue UI)
Flows: <the user-facing flows to exercise, happy path first>
Async: <how to trigger background work; states to watch, e.g. queued → done | failed>
Data: <records/accounts that exist, and how to create more>
Login: <saved session, or test credentials>
Out of scope: <anything deliberately not tested>
```

Every field above is required when it applies: URL, apps to run (incl.
background/realtime deps), flows, how to trigger async work, seed data/states
to check. A brief without them gets `BLOCKED: incomplete brief`. The tester
figures out the steps, selectors, and edge cases from the code. This skill is
the only way to run `qa-tester`.

## 6. Release and report

After the verdict, always `qa-lease release` (when you acquired), PASS, FAIL
or BLOCKED. It restores the main worktree and the database. Report the
verdict, findings, and the "Not tested" list. `BLOCKED` is never a pass. If
the tester blocked on something you can fix, fix it, then run again.
