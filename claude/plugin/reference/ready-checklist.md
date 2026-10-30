# Ready checklist

What a branch needs before its PR leaves draft (`gh pr ready`, or `gh pr
create` / `gh stack submit` without `--draft`). Every box checked against
the current HEAD, or the PR stays a draft. Used by project agents
(`start-ticket`) and after `address-pr-comments` fixes.

## File

`$HOME/screenshots/<repo>/<branch>/ready.md` (beside the review reports;
`/` in the branch → `-`). Create it from the template when code is done.

```markdown
# Ready: <branch>
HEAD: <sha>

- [ ] History: no `WIP:` commits; Conventional Commits with the ticket
      scope; rebased on base (stack: `gh stack sync`)
- [ ] Deep review: `/deep-review --fix` reached steady state
- [ ] Checks: the repo's lint, typecheck, tests pass
- [ ] Spec: no open spec-audit questions; the diff covers the ticket
- [ ] PR description: body per `voice.md` → PR descriptions (screenshots
      or video for UI changes); title matches the repo's CI title regex
- [ ] Threads: every review thread fixed, replied (draft posted on the
      user's OK), or ticketed (`pr-threads <pr>`); no PR or no threads → n/a
```

Check a box as its item finishes: `- [x] <item> · <YYYY-MM-DD> · <evidence>`
(report path, command and result, thread count).

## Reset

Any new commit clears the list. Before reading or checking a box, compare
`HEAD:` with `git rev-parse HEAD`; different → uncheck every box, write the
new sha, start again from the top. Items run top to bottom because only the
first two can commit (history rewrite, fix loop), and a commit restarts the
list. Done = every box checked and `HEAD:` equals HEAD.

## Ready

All checked → tell the user and offer `gh pr ready` (stack: per layer;
only the bottom layer leaves draft, per `gh-stack.md`). Pushing and
`gh pr ready` still wait for the user's OK. Not all checked → the PR
stays a draft: list the open items.
