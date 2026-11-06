# Probe mode

No browser, no desk: runs from this worktree (or the caller's review
worktree), so nothing queues. These rules bind both the plan (you) and the
run (`qa-tester`), on top of `qa-tester` → Testing (hypotheses, blast
radius, settle by running, assert state), which the plan follows too.

## P1. Plan: how would you test this for real?

Write the probe plan from the diff, the intent, and the code: the Testing
plan, plus:

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
- **Failure matrix** (required): invalid enum/off-list value, missing
  dependency, partial API failure mid-run (each call, e.g. POST after
  DELETE), re-run idempotency (same input, new input), shell differences
- **Versions**: pre-fix (`git show <sha>^:<file>`; proves the matrix
  catches the bug), head, every proposed fix (reviewers' and ours)
- **Out of reach**: what this sandbox can't cover, and what would

## P2. Run

Graders first, when the plan has them: spawn 2 agents in parallel, each
given only the artifact and the sample, no rubric hints or each other's
output; save each output to the Graders dir.

Then spawn `qa-tester` directly (Agent tool, no desk) with:

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

## P3. Report and teardown

Relay qa-tester's report (verdict, coverage, scenario table, Deeper
coverage). List every sandbox still live; deleting an outward one (e.g. a
scratch repo) asks the user first.
