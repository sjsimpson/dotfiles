# gh stack

## Slicing

- Layers are tracer bullets: each cuts a thin, complete path (schema → API
  → UI → tests) that can be demoed or verified on its own, not one
  horizontal layer of the stack
- Prefactoring goes in the bottom layer ("make the change easy, then make
  the easy change")
- Each layer names what it's blocked by; a stack is a straight line, so
  independent work goes in its own stack
- Wide mechanical refactor (rename a column, retype a shared symbol) that
  can't land green in one slice → expand–contract: add the new form beside
  the old, migrate callers in batches (one layer each), then delete the old
  form last

## Flow per layer

1. Layer below merged → `gh stack sync` (fetch, rebase the whole stack)
2. `gh stack checkout <next>` → `/deep-review --fix`: review + QA on
   local commits, fix, repeat until steady state
3. Report → the user decides: `gh stack push`, `gh pr ready`
4. Merge one layer at a time (global CLAUDE.md)

## Pitfall: plain git rebase on a stack branch

`git rebase origin/main` + force-push leaves gh stack's saved base for that
branch stale; `gh stack rebase` (even `--upstack`) then replays main's own
commits and conflicts. Rebase stack branches only with `gh stack
sync|rebase`.

Recovery:
1. On the broken branch: `git rebase origin/main`
2. Each layer above, bottom up: `git rebase --onto <branch below>
   <old head of branch below> <layer>`
3. Still broken → ask the user: `gh stack unstack` (also removes it on
   GitHub) + `gh stack init`
