---
name: claude-panel
description: "Local Claude PR review panel: parallel lens finders + repo `*-reviewer` agents, blind validation, no QA (callers run `qa`); report in chat, and on others' PRs the findings go into my pending review (never submitted). Use for /claude-panel, or when deep-review / review-stack call it."
argument-hint: "[pr-number | pr-url | --local] (optional — defaults to current branch's PR)"
---

# Claude Review Panel (local)

Preflight inline, then one Workflow run (`panel.workflow.js`, next to this file) does find → merge → blind-validate. Output is a **local report**; on others' PRs the findings also go into my pending review (Step 4). Nothing else goes to GitHub unless the user asks.

## Rules

- **GitHub writes:** others' PRs → pending review after the report, automatically (Step 4); skipped when the caller says local only (e.g. `/deep-review`, which syncs it itself). My own PRs → never a pending review. Checkbox tick / public comments only on explicit request.
- **Read-only everywhere.** No edits, `pnpm install`, or test runs in any worktree — safe on fork PRs.
- Never touch the user's working tree for someone else's PR; use a disposable worktree.
- Each Bash call is a fresh shell — start every call with `SCRATCH="${TMPDIR:-/tmp}"; SCRATCH="${SCRATCH%/}/claude-panel"`.
- Every `gh pr` call carries `<n>` explicitly.

## Step 0: Preflight (one batched Bash call)

First, alone: `ps -p $$ >/dev/null 2>&1 || echo SANDBOXED`. Sandboxed → tell the user the panel needs unsandboxed Bash and stop.

Arg: PR number or URL (extract number); none → `gh pr view --json number -q .number`.

**`--local`**: review the current branch's local commits instead of the PR head on GitHub, so fixes can change before pushing. Uncommitted changes → stop, ask for a `WIP:` commit. `headSha` = `git rev-parse HEAD`; base = the PR's base if one exists, else the gh stack parent (`gh stack view --json`), else the default branch. No PR → number `local-<branch>`, intent from `git log origin/<base>..HEAD`, empty raised list. Skip the REST pin and the draft/closed checks; `WORKDIR` = repo root; never a pending review (own work).

```bash
gh api 'repos/{owner}/{repo}/pulls/<n>' --jq '{state, draft, title, base: .base.ref, head: .head.ref, headSha: .head.sha, author: .user.login, mergeable_state, body, fork: (.head.repo.full_name != .base.repo.full_name)}'
gh api user -q .login
pr-threads <n>
grep "\"pr\":<n>," ~/.claude/claude-panel-runs.jsonl 2>/dev/null | tail -1
```

Pin `headSha` from REST (`gh pr` GraphQL caches stale heads). Then:

- Closed/merged → stop. Draft → ask.
- Last run log line has same `headSha` → already done for this head; ask before re-running. Different `headSha` → `git diff --name-only <old> <headSha> -- <PR paths>`: empty = rebase only, ask; non-empty = delta pass, pass those files as `focusFiles`.
- **Raised list**: `pr-threads` lines (threads any status, my `PENDING` comments, substantive review bodies and PR comments; any author). Drop bot noise (CI summaries, walkthroughs). Resolved/declined threads stay in: findings that repeat them are dropped too.

## Step 1: Workspace

```bash
mkdir -p "$SCRATCH"
git fetch origin "<base>"
git fetch origin "refs/pull/<n>/head"            # separate fetch; combined breaks FETCH_HEAD
[ "$(git rev-parse FETCH_HEAD)" = "<headSha>" ] || echo "HEAD MOVED — re-pin"
```

- `--local` → only `git fetch origin "<base>"`; `WORKDIR` = repo root.
- Current branch's PR, `HEAD == headSha`, clean tree → `WORKDIR` = repo root.
- Else → `RUN=$(date +%Y%m%d-%H%M%S); git worktree add --detach "$SCRATCH/pr-<n>-$RUN-wt" <headSha>`; `WORKDIR` = that.

`git -C "$WORKDIR" diff origin/<base>...<headSha> > "$SCRATCH/pr-<n>.diff"`; stop if empty. Always diff against `origin/<base>`, never local `main`.

Banner flags (for the report): >500 changed lines / >20 files; `mergeable_state == dirty`; **sensitive paths** (auth/middleware, billing/payments, secrets/`.env*`, DB schema/migrations, public API, anything moving money or filing returns) → "human expert sign-off required".

Repo reviewer agents: `ls .claude/agents/*-reviewer.md 2>/dev/null` in the repo root → names (filename minus `.md`).

## Step 2: Run the workflow

Invoking this skill is the user's opt-in to the Workflow. Call:

```
Workflow({
  scriptPath: "<this skill's base directory>/panel.workflow.js"  (absolute; normally ~/.dotfiles/claude/plugin/skills/claude-panel),
  args: {
    number, title, intent: <PR body, comments/template boilerplate stripped>,
    spec: <linked Linear ticket's description + `## Update` sections (get_issue), or "">,
    workdir: <absolute WORKDIR>, base, headSha, diffPath: <absolute>,
    raised: <raised list text, or "">,
    repoAgents: [<names>],
    escalate: <true if sensitive paths touched>,
    focusFiles: <delta files or null>,
    skipLenses: <e.g. ["tests"] for docs/config-only PRs, else []>
  }
})
```

Pipeline and lenses: `panel.workflow.js` (the source of truth).

While it runs, don't poll — the completion notification wakes you. If it dies, re-invoke with `resumeFromRunId`; finished agents return cached.

## Step 3: Report (local)

Re-pin head (`gh api .../pulls/<n> --jq .head.sha`; `--local`: `git rev-parse HEAD`). Moved → `git diff --name-only <reviewed> <new>`; mark findings in changed files "may be fixed/moved".

Re-run `pr-threads <n>` (not `--local` without a PR): asks raised since Step 0 join the raised list, and findings that repeat them are dropped.

Build the shared report (`report.md` in the plugin's `reference/` dir, `<this skill's base directory>/../../reference/report.md`), its sections as bold labels. Print it in chat, except when Step 4 syncs a pending review: then write it to `~/screenshots/<repo>/<branch>/pr-<n>-panel.md` and chat gets the short form (report.md, after a sync).

1. **Verdict**: approve / request changes, never comment (advisory only; rules: `report.md` → Verdict), plus the banner (sensitive / large / conflicted / head moved), if any.
2. **Findings** (confirmed + codified), grouped by `action`, then severity, then confidence:
   - **Fix · blocking**: `**path:line** [sources · severity · conf] — claim` + one-line evidence + `harm` + `fix` as a code block when present
   - **Fix · non-blocking**: same line, no `harm`. Never changes the verdict
   - **Ticket** (codebase-wide): same line + `note` (the pattern and where else it applies)
   - **Skip**: one line each with `reason` and `note`, so the user can override
   - **Uncertain** (major+ only, one-liners): worth a human look
   - **Refuted**: one line each with evidence, so the user can override
3. **Earlier asks**: raised-list items findings matched, one line each.
4. **Not verified**: agents that failed or were out of scope (ran / out-of-scope / failed). Never present a failed agent as clean.

Save the full workflow result to `$SCRATCH/pr-<n>-<headSha:0:8>.json`, and append one line to `~/.claude/claude-panel-runs.jsonl`:

```json
{"pr":<n>,"repo":"<owner/repo>","headSha":"...","date":"YYYY-MM-DD","agents":{"correctness":{"found":N,"confirmed":N},...}}
```

(per-source found vs confirmed — over time this is the hit rate for pruning/tuning lenses).

Completion ping: `osascript -e 'display notification "PR #<n>: <k> findings" with title "claude-panel"' 2>/dev/null`.

## Step 4: Follow-ups

My own PR: offer in one line at the end: "Want fixes applied (or the checkbox ticked)?" No pending review.

**Pending review** (others' PRs, automatic after the report unless the caller said local only; invisible to others until the user submits in the UI):

- Comment body and which findings to post: `voice.md` → PR feedback (blocking ones only; non-blocking stay in the report, and `deep-review` fixes the mechanical ones). No sources or finding ids in the body.
- Review body: report.md → **Pending review body** (voice.md → Review bodies: 1-3 sentences, then unanchored findings). Only diff lines anchor; others go in the body. Each comment stands alone. Approve with no findings → empty body (report.md → Approve with no findings).
- Write `$SCRATCH/pr-<n>-findings.json` (`{body, comments:[{path, line, startLine?, body}]}`), then `pr-pending sync <n> "$SCRATCH/pr-<n>-findings.json" --ledger "$SCRATCH/pr-<n>-pending-comments.json"`. It appends to my existing pending review or starts one, never submits. Give its counts and link at the end of the report.

**Tick the template checkbox** (only when asked; re-fetch body first — author may have edited):

```bash
gh api 'repos/{owner}/{repo}/pulls/<n>' --jq '.body // ""' > "$SCRATCH/pr-<n>-body.md"
sed 's/^- \[ \] Reviewed by AI review panel\([[:space:]]*\)$/- [x] Reviewed by AI review panel\1/' \
  "$SCRATCH/pr-<n>-body.md" > "$SCRATCH/pr-<n>-body-ticked.md"
cmp -s "$SCRATCH/pr-<n>-body.md" "$SCRATCH/pr-<n>-body-ticked.md" \
  || gh api -X PATCH 'repos/{owner}/{repo}/pulls/<n>' -F body=@"$SCRATCH/pr-<n>-body-ticked.md"
```

No match → say so; never inject the line.

**Apply fixes** (own PR): hand off to `/address-pr-comments` with this run's result file; it gates on a decision table, fixes in the owning branch, and handles tickets. For a whole stack, use `/review-stack`.

## Step 5: Cleanup

`git worktree remove` this run's `pr-<n>-<RUN>-wt` only (never the repo root), then `git worktree prune`. Mention other `claude-panel/pr-*-wt` leftovers; remove only on confirmation.
