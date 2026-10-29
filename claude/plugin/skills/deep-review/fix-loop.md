# Fix loop (`--fix`)

In-session only, my own work; you asked for the fixes, so no decision-table
gate. Never push. Round k (cap 10):

1. Review + QA on local HEAD, as 3b (`claude-panel --local`, qa both passes)
2. Fix: the panel's `fix` findings and QA bugs. Apply per
   `address-pr-comments` Step 4 (owning branch, its commit mode,
   Conventional Commits with the ticket scope, verify). `ticket` / `skip`
   (separate effort, not worth it, codebase-wide) → not done, listed
3. Steady state → stop: no blocking findings and QA PASS (non-blocking
   fixes from this round applied; they don't force another round), or only
   repeats of earlier skips/tickets. Else next round on the new HEAD

Report (shared template, report path from step 1 with `-fix`): per round
one line (found / fixed / commits), final verdict, Ticket candidates (not
created), Skips with reason, Not verified. Then offer: push (stack: `gh
stack push`), `gh pr ready`, merge prerequisites into the PR body (short,
per `voice.md` → PR descriptions). Nothing
without my OK, except attaching the best shots/video once the PR is opened
(same rule).
