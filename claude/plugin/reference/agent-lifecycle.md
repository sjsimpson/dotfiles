# Agent lifecycle

Herdr agents a dispatcher starts for one ticket or PR: `start-ticket`
project agents and `deep-review` reviewers. Each lives from dispatch to
merge; in between the user works with it in its own pane.

## Start (dispatcher)

- **Name**: `<ticket>` (reviewers: per `deep-review`). `ListAgents`
  already shows it → tell the user and offer: message that agent, or start
  `<ticket>-2` (then `-3`, …). Say the name you used
- **Fresh branch**: a worktree created on an existing branch checks out the
  local one, which can be stale (`--base` only applies to new branches).
  After create: `git -C <wt> fetch -q origin <branch>` then
  `git -C <wt> merge --ff-only origin/<branch>`. Not a fast-forward (local
  commits diverged) → stop and tell the user

## Handoff

The user works with the agent in its pane. The dispatcher logs the agent's
messages and relays none of them, except blockers; it never answers the
agent's questions. Messages to `<reply-to>`, one line each:

- **Log pings**: "`<ticket>` audit: `<verdict>`, N questions, grilling in
  pane" (start-ticket); "`<ticket>` #`<n>` review round done (`<state>`),
  parked until merge" (deep-review: after the user's review, the reviewer
  stays for re-review on new pushes when the user asks)
- **Blockers**: setup broken, QA desk down, login expired (`qa-login
  <url>`). The dispatcher passes these on

## Done (agent)

Work ends when the PR (or the whole stack) is merged or closed, the Linear
ticket is canceled, or the user says done. A review round ending is not
the end. The agent can't see merges: the dispatcher's triage messages it
with the event. Verify (`gh pr view <n> --json state`, `get_issue`), then
SendMessage `<reply-to>`: "`<ticket>` done (`<MERGED | CLOSED | CANCELED |
done>`), ready to spin down", plus any uncommitted or unpushed work. Then
stop.

## Cleanup (dispatcher)

On a done message, check the worktree:

- **Clean**: `git -C <wt> status --porcelain` empty, and nothing unpushed:
  `git -C <wt> log @{u}..` empty; upstream gone (a merge deletes the
  branch) → `git -C <wt> fetch -q origin refs/pull/<n>/head` and HEAD is
  that sha or its ancestor (`git merge-base --is-ancestor HEAD
  FETCH_HEAD`). No PR and no upstream → not clean
- Clean → remove without asking: worktree created for it → `herdr worktree
  remove --workspace <id>`; reused worktree → `herdr tab close <tab>`.
  Else list what's there and ask first
