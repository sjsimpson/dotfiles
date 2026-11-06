# Agent lifecycle

Herdr agents a dispatcher starts for one ticket or PR: `start-ticket`
project agents and `deep-review` reviewers. Each lives from dispatch to
merge; in between the user works with it in its own pane.

## Start (dispatcher)

- **Name**: the ticket lowercased (`eng-1234`). `ListAgents` already
  shows it → tell the user and offer: message that agent, or start
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
  watching" (deep-review: after the user's review, the reviewer stays and
  re-reviews on new pushes, per Watch)
- **Blockers**: setup broken, QA desk down, login expired (`qa-login
  <url>`). The dispatcher passes these on

## Watch (agent)

Once a PR exists, the agent keeps a watcher armed on it: `pr-watch <n> -R
<owner/repo> --as <author | reviewer>` via Bash `run_in_background`. It
polls gh for free and exits on the first change; the exit wakes the agent.
Arm it when the PR opens (project agent; its own pushes restart CI
tracking without a wake) or after the first review round (reviewer). One
watcher per PR, and a stack gets one per layer. On wake, handle every
event line, then re-arm that PR's watcher:

- **Merged / closed**: the last open PR → Done. A lower stack layer → the
  next layer up is now the bottom: `gh stack sync`; it rewrote layers →
  offer the push (user's OK); the next CI pass runs the ready step below
- **Project agent** (`author`): CI failed → root cause from the log (`gh
  run view <id> --log-failed`) and a proposed fix. New comments or reviews
  → `address-pr-comments` decision table. Both wait for the user's OK in
  the pane before any commit. CI passed → walk `ready-checklist.md`; a
  draft that is the bottom layer (or a lone PR) with every box checked →
  offer "CI green, checklist done: mark #`<n>` ready?" and run `gh pr
  ready <n>` on the user's OK. Not ready → "CI green; not ready:
  `<open checklist items>`"
- **Reviewer**: new push that only rebases (`git range-diff <base at
  review>..<reviewed sha> <base now>..<new sha>` marks every commit `=`) →
  one line "rebased, no change", no re-run. Otherwise, new push or re-review requested →
  re-run the review on
  the delta (deep-review brief's re-run line: panel + QA on what changed
  since the report's head), sync the pending review, then tell the user
  in the pane and log-ping `<reply-to>`: "`<ticket>` #`<n>` re-reviewed
  (`<sha7>`): `<verdict>`". New comments only → re-read threads
  (`pr-threads`), update Earlier asks; re-run only if they change a
  finding
- **No change in 72h** → re-arm

## Done (agent)

Work ends when the PR (or the whole stack) is merged or closed, the Linear
ticket is canceled, or the user says done. A review round ending is not
the end. The watcher reports merges and closes; a canceled ticket arrives
from the dispatcher's triage. Verify (`gh pr view <n> --json state`, `get_issue`), then
SendMessage `<reply-to>`: "`<ticket>` done (`<MERGED | CLOSED | CANCELED |
done>`), ready to spin down", plus any uncommitted or unpushed work. Then
stop.

## Cleanup (dispatcher)

On a done message, check the worktree:

- **Clean**: `git -C <wt> status --porcelain` empty, and nothing unpushed:
  `git -C <wt> log @{u}..` empty; upstream gone (a merge deletes the
  branch) → PR number from `gh pr list --head <branch> --state all --json
  number`, then `git -C <wt> fetch -q origin refs/pull/<n>/head`; HEAD is
  that sha or its ancestor (`git merge-base --is-ancestor HEAD
  FETCH_HEAD`). No PR and no upstream → not clean
- Clean → remove without asking: worktree created for it → `herdr worktree
  remove --workspace <id>`; reused worktree → `herdr tab close <tab>`.
  Else list what's there and ask first
