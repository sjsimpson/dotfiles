# gh stack

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
