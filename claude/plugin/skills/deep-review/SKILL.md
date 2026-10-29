---
name: deep-review
description: Full review + in-app QA of a PR (claude-panel + qa, prod data read-only), in this session or in its own herdr worktree + agent. Modes --fix, --status, --risky, --stack. Use for /deep-review or to review/QA a PR; proactively --fix (no PR needed) once code on my branch is finished, before reporting done.
argument-hint: "[pr-number | pr-url] [--status] [--risky] [--stack] [--fix] [extra context]"
---

# Deep review

Where it runs:

- **In-session**: the PR's head branch is checked out in this session's
  worktree and the user is working on it. You run the brief's steps
  yourself (**In-session** below)
- **herdr**: anything else (e.g. someone else's PR). The agent works in its
  own worktree and pane; you dispatch and relay

## 0. Inputs

- PR: number or URL. URL → `owner/repo`; number → current repo
  (`gh repo view --json nameWithOwner`). `--fix` without one: the current
  branch's PR if any, else no PR: skip the `gh pr view` and thread reads,
  base = gh stack parent or default branch, `pr-<n>` → branch name
- Repo name = last part of `owner/repo`. Local checkout: the main worktree
  of that repo (ask if you can't find it)
- Private repo config: `~/.config/claude-repos/<repo>/review.md` (prod data source,
  setup notes, QA gotchas, risky areas). Read it; missing → say so, carry on
  without a prod pass (the report must then say prod wasn't checked)
- Mode: `--status` (my own PR), else review. Never pass or assume a mode
  the user didn't give; ask (step 1). `--risky` adds on to either. Also
  risky, unasked, when the diff touches an area the repo config lists as
  risky: say so. `--stack` combines with any of them (see **Stack**).
  `--fix`: my own PR or layer, checked out here (else stop); see **3c**
- Reply-to (herdr): this session's name (`ListAgents` shows it). No name → the agent
  can't message back: tell the user to name the session, or rely on the
  report file only

## 1. Gather (one batched call)

```bash
gh pr view <n> -R <owner/repo> --json number,title,author,headRefName,headRepositoryOwner,baseRefName,state,isDraft,reviewDecision,mergeStateStatus,body,url,files
gh api user -q .login
git -C <checkout> worktree list --porcelain   # where <head> is checked out
git branch --show-current                      # this session's branch
```

- Closed/merged → stop. Fork PR → stop: `qa` runs only same-repo code
- Ticket = `[A-Za-z]+-[0-9]+` from title, else branch (uppercase it), else
  `pr-<n>`; agent name = ticket lowercased (`out-1200`)
- Author is me and no mode given → ask: `--status` or review?
- Review mode: `ListAgents` should show `qa-desk-<repo>`. Not there → warn
  the user (QA will block until it's started) before dispatching
- Report path: `$HOME/screenshots/<repo>/<head, / → ->/pr-<n>-<review|status>.md`.
  Already exists → re-run: the brief's re-run line applies
- Where: current branch = head → **In-session** (step 3b); else herdr
  (step 2)

## 2. Worktree + agent (herdr)

```bash
git -C <checkout> fetch -q origin <head>
HERDR_ENV=1 herdr worktree create --cwd <checkout> --branch <head> \
  --base origin/<head> --label "<ticket> <review|status>" --no-focus
herdr-sort   # projects (incl. status) above reviews in the sidebar
```

Branch already checked out in another worktree → reuse it (the brief gets
the shared-worktree line); new tab for the agent:
`herdr tab create --workspace <id> --cwd <path> --label "<ticket> <mode>"`.
Pane id: from the create output. Then write the brief (step 3) to
`<report dir>/pr-<n>-brief.md` (kept for re-runs) and:

```bash
herdr agent start <agent> --kind claude --pane <pane> -- -n <agent>
herdr agent prompt <agent> "$(cat <report dir>/pr-<n>-brief.md)"
```

No `--wait` on prompt: it times out while the agent works. Confirm it
started: `herdr agent wait <agent> --until working --timeout 60000`
(`agent get` can say idle right after a prompt; `herdr pane read <pane>`
to see why it isn't working).

## 3. Brief

Fill every `<…>`; paste the repo config's sections in where marked. Keep it
in this order.

```
Task from the user (via <reply-to>): <review | status check> PR
<owner/repo>#<n>, "<title>" (author <author>). Worktree on branch <head>.
<extra context from the user, if any>
<reused worktree: Worktree shared with <reply-to>. Don't switch branches or
 edit files>
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
5. /sjsimpson:qa, app or probe mode per change (its step 0), brief
   Evidence: <report dir>. Probe mode: its plan, failure matrix, and
   versions (pre-fix, head, each proposed fix). Both passes, neither
   optional:
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
- No GitHub writes at all: no push, approve, request changes, comments,
  or pending review (<reply-to> syncs that). No code edits (status mode:
  only as above)
- Prod data read-only. Internal IDs only: no customer names, amounts,
  account numbers, or other customer details in the report
- Don't block on questions: note assumptions and carry on. Hard blocker
  (no prod access, app won't start, can't log in, QA desk missing) →
  message <reply-to>, then finish what you can

Deliverable
Write <report path> (not a scratchpad or /tmp) as the shared report
(~/.dotfiles/claude/plugin/reference/report.md): Verdict (status mode:
mergeable now / needs X, with the path to merge), Findings (drafts per the
`voice.md` → PR feedback, only ones worth the author's time), Earlier asks,
QA per pass with screenshot paths, Safety (risky only), Not verified.
Review mode, author isn't the user: also write the findings that anchor to diff lines as
<report dir>/pr-<n>-findings.json ({"body": "<Pending review body per
report.md (voice.md → Review bodies), then findings with no line>",
"comments": [{"path", "line", "startLine"?, "body"}]}, bodies exactly as in
the report). Approve with no findings → "body": "" and no comments
(report.md → Approve with no findings).
Then SendMessage <reply-to>: one line, verdict, report path, findings.json
path if any.
```

## 3b. In-session

The brief (step 3) is your checklist; skip setup step 1 (already set up)
and the Deliverable's SendMessage. Run `claude-panel --local` (reviews the
local commits) and qa from here; QA
desk replies wake you. While it runs: no branch switch, no code edits
(status mode: only when the user says so, after a `WIP: snapshot`).

## 3c. Fix loop (`--fix`)

Follow `fix-loop.md` (this skill's folder).

## 4. Findings → pending review or fixes (you)

**My own PR** (not `--fix`): no pending review. Findings → offer to fix them
(`/address-pr-comments` with the report). Passing verdict → also offer
`gh pr ready <n>` and adding merge prerequisites the review found to the PR
body. Nothing without my OK.

**Others' PR** (review mode): when the agent reports (or 3b finishes), sync
its findings. QA `BLOCKED` → sync nothing; tell the user what's blocked and
troubleshoot here, then re-run:

```bash
pr-pending sync <n> -R <owner/repo> <report dir>/pr-<n>-findings.json \
  --ledger <report dir>/pr-<n>-pending-comments.json --run <ticket>-<head sha:8>
```

Adds to the user's pending review (or starts one) and sets its body (what
was tested); on re-runs only updates/removes comments and a body it posted
that the user hasn't edited. Body skipped as not the agent's → tell the
user; `--replace-body` only on their OK. Never
submits. Add its counts (added / replaced / removed / skipped + why) and
the review link under the report's Verdict (rules: `report.md` → Verdict). Chat: the short form (report.md, after a sync), with the report
path.

## 5. Cleanup (herdr)

When the user's done with the reviewer (herdr has no agent kill): worktree
created for the review → `herdr worktree remove --workspace <id>`; reused
worktree → `herdr tab close <tab>`. Report, brief, findings, ledger, and
pending review stay.

## Stack (`--stack`)

Follow `stack.md` (this skill's folder).

## 6. Log + report

This session works in `~/notes` (the assistant) → append to
`~/notes/assistant/log/<YYYY-MM>.md`:
`- <date>: <ticket> (#<n>) <mode> dispatched: herdr worktree "<label>", agent \`<agent>\``.
Any other session: skip (not its repo).

Tell the user: agent name, worktree label, report path to expect (herdr).
The agent's message wakes you; relay its verdict, path, and step 4's
outcome.

## Never

Post publicly, submit, push, or approve; edit code outside `--fix` or status mode on the user's ask; write to prod data; run
or brief a review without both claude-panel and qa (review mode). Your one
GitHub write is `pr-pending sync` (others' PRs).
