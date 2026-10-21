---
name: deep-review
description: Hand a PR to its own herdr worktree + Claude agent for a full review and in-app QA, reported back to this session. The agent always runs claude-panel AND qa, tests against real production data read-only where possible, and never posts, pushes, or edits code. Modes - default (someone else's PR), --status (my own PR, merge readiness), --risky (code that can touch real external systems or money), --stack (every PR in a stack, one agent per layer, then a stack-wide summary). Use when the user asks for /deep-review, or to have a PR reviewed/QA'd in its own worktree.
argument-hint: "<pr-number | pr-url> [--status] [--risky] [--stack] [extra context]"
---

# Deep review

You dispatch; the agent does the work in its own worktree and pane. You never
review, post, or edit anything yourself.

## 0. Inputs

- PR: number or URL. URL → `owner/repo`; number → current repo
  (`gh repo view --json nameWithOwner`)
- Repo name = last part of `owner/repo`. Local checkout: the main worktree
  of that repo (ask if you can't find it)
- Private repo config: `~/.config/claude-repos/<repo>/review.md` (prod data source,
  setup notes, QA gotchas, risky areas). Read it; missing → say so, carry on
  without a prod pass (the report must then say prod wasn't checked)
- Mode: `--status` (my own PR), else review. `--risky` adds on to either. Also
  risky, unasked, when the diff touches an area the repo config lists as
  risky: say so. `--stack` combines with any of them (see **Stack**)
- Reply-to: this session's name (`ListAgents` shows it). No name → the agent
  can't message back: tell the user to name the session, or rely on the
  report file only

## 1. Gather (one batched call)

```bash
gh pr view <n> -R <owner/repo> --json number,title,author,headRefName,headRepositoryOwner,baseRefName,state,isDraft,reviewDecision,mergeStateStatus,body,url,files
gh api user -q .login
```

- Closed/merged → stop. Fork PR → stop: `qa` runs only same-repo code
- Ticket = `[A-Za-z]+-[0-9]+` from title, else branch (uppercase it), else
  `pr-<n>`; agent name = ticket lowercased (`out-1200`)
- Author is me and no mode given → ask: `--status` or review?
- Review mode: `ListAgents` should show `qa-desk-<repo>`. Not there → warn
  the user (QA will block until it's started) before dispatching
- Report path: `$HOME/screenshots/<repo>/<head, / → ->/pr-<n>-<review|status>.md`.
  Already exists → re-run: the brief's re-run line applies

## 2. Worktree + agent

```bash
git -C <checkout> fetch -q origin <head>
HERDR_ENV=1 herdr worktree create --cwd <checkout> --branch <head> \
  --base origin/<head> --label "<ticket> <review|status>" --no-focus
```

Branch already checked out in a worktree → reuse that worktree, don't
create one. Pane id: from the create output, else
`herdr pane list --workspace <id>`. Then write the brief (step 3) to
`<report dir>/pr-<n>-brief.md` (kept for re-runs) and:

```bash
herdr agent start <agent> --kind claude --pane <pane> -- -n <agent>
herdr agent prompt <agent> "$(cat <report dir>/pr-<n>-brief.md)"
```

No `--wait`: it times out while the agent works. `herdr agent get <agent>`
once to confirm it's working.

## 3. Brief

Fill every `<…>`; paste the repo config's sections in where marked. Keep it
in this order.

```
Task from the user (via <reply-to>): <review | status check> PR
<owner/repo>#<n>, "<title>" (author <author>). Worktree on branch <head>.
<extra context from the user, if any>
<stack: Layer <i> of <N> (bottom → top: #a, #b, …). Review only this
 layer's diff vs <base>. Problems a lower layer introduced belong to it:
 note them, don't re-raise>
<re-run: read <report path> first; review what changed since its head sha.
 For each earlier finding, check pr-threads: posted (a thread matching it)?
 resolved, declined, or open at head? Don't re-raise posted or declined
 ones; report their status under Earlier asks>

Setup
1. git branch --set-upstream-to=origin/<head>, then this repo's normal
   worktree setup so the app runs. <repo config: setup notes>
2. Check you have the prod data tool (<repo config: prod data source>).
   Missing → hard blocker (below)
3. Read every existing review thread: `pr-threads <n> -R <owner/repo>`
   (`--json` for full bodies), plus any linked issue-tracker review
   thread. List each earlier ask with its status at head: resolved /
   not / partly, with evidence

Review (review mode)
4. /sjsimpson:claude-panel <n>. Local only, post nothing
5. /sjsimpson:qa, mostly UI/in-app. Both passes, neither optional:
   a. Prod: read-only via the prod data tool. Find real cases the change
      affects (accounts, periods, records) and confirm the new behavior on
      each, by reproducing the shape locally or reasoning from the code.
      Query only; never write
   b. Local: only for data that doesn't exist in prod yet (new feature,
      new state). Generate realistic local data (seed or fudge) mirroring
      prod shapes. Cover edge cases: empty/zero, mixed, error paths, and
      cases that must stay unchanged
   Flag-gated code: test flag on and off. <repo config: QA gotchas>

Status (status mode, replaces 4-5)
4. CI: each failing job, root cause from its log
5. Open threads, review decision, ruleset (dismiss-stale, thread
   resolution required), mergeable state; rebase dry run on a throwaway
   branch (never rewrite <head>)
6. Path to merge: ranked blockers, each fix / rebase / re-review. No QA
   unless asked above. The user may drive in this pane: edit code only when
   they say so here, after a `WIP: snapshot` commit

Risky (only when risky) - read first
- NEVER log in to, fill, or submit anything on a real external system, or
  use real credentials. Mocks, recorded fixtures, stub servers, or the
  code's dry-run/test mode only. Can't test without the real thing → skip
  it and say so
- Scrutinize every path that could act for real: idempotency, double
  submit, partial failure, retry, the guards deciding what runs
  automatically. Report gets a Submission safety section

Hard rules
- No push, comment, approve, request changes, or code edits (status mode:
  only as above). GitHub writes, even pending-review comments, are a
  separate step the user drives in this pane
- Prod data read-only. Internal IDs only: no customer names, amounts,
  account numbers, or other customer details in the report
- Don't block on questions: note assumptions and carry on. Hard blocker
  (no prod access, app won't start, can't log in, QA desk missing) →
  message <reply-to>, then finish what you can

Deliverable
Write <report path> (not a scratchpad or /tmp) as the shared report
(~/.dotfiles/claude/plugin/reference/report.md): Verdict (status mode:
mergeable now / needs X, with the path to merge), Findings (drafts per the
global PR feedback rule, only ones worth the author's time), Earlier asks,
QA per pass with screenshot paths, Safety (risky only), Not verified.
Then SendMessage <reply-to>: one line, verdict + report path.
```

## Stack (`--stack`)

Layers from the PR's base chain, open PRs only:

```bash
gh pr list -R <owner/repo> --head <base> --state open --json number,headRefName,baseRefName   # parent; repeat down to the default branch
gh pr list -R <owner/repo> --base <head> --state open --json number,headRefName               # child; repeat up. Several → ask which
```

- Bottom → top. One layer → plain run. More than 4 → state the count and
  ask (each layer is a full panel + QA)
- Per layer: steps 1-3 as above, own worktree, agent and report, brief with
  the stack line. Dispatch all at once; the QA desk queues their QA
- Track the layers; each agent's message wakes you. When all are in (or
  blocked), write `$HOME/screenshots/<repo>/stack-<bottom head>/stack-review.md`
  as the shared report: Verdict per layer + overall; Findings merged across
  layers (same problem twice → one item, owned by the lowest layer that
  introduced it; fixes that cascade to upper layers noted); Earlier asks,
  QA, Not verified as links to each layer's report
- My own stack → offer `/address-pr-comments stack` with the layer reports
  and the summary

## 4. Log + report

This session works in `~/notes` (the assistant) → append to
`~/notes/assistant/log/<YYYY-MM>.md`:
`- <date>: <ticket> (#<n>) <mode> dispatched: herdr worktree "<label>", agent \`<agent>\``.
Any other session: skip (not its repo).

Tell the user: agent name, worktree label, report path to expect. The
agent's message wakes you; relay its verdict and path.

## Never

Post, push, approve, or edit code yourself; write to prod data; brief an
agent without both claude-panel and qa (review mode).
