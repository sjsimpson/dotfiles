---
name: claude-panel
description: Local, Claude-only PR review panel — parallel lens finders + repo `*-reviewer` agents, blind validation, plus a qa-tester run for same-repo UI PRs, report in chat; posts nothing to GitHub unless asked afterward. Use ONLY when the user explicitly asks (`/claude-panel [pr]`).
argument-hint: "[pr-number | pr-url] (optional — defaults to current branch's PR)"
---

# Claude Review Panel (local)

Preflight inline, then one Workflow run (`panel.workflow.js`, next to this file) does find → merge → blind-validate. Output is a **local report**. Nothing goes to GitHub unless the user asks after seeing it.

## Rules

- **No GitHub writes by default.** Reads only. Pending review / checkbox tick / comments only on explicit request after the report (Step 4).
- **Read-only everywhere.** No edits, `pnpm install`, or test runs in any worktree — safe on fork PRs. One exception: Step 2b's QA run (same-repo PRs only), which runs the PR's code in the app via the `qa` skill.
- Never touch the user's working tree for someone else's PR; use a disposable worktree.
- Each Bash call is a fresh shell — start every call with `SCRATCH="${TMPDIR:-/tmp}"; SCRATCH="${SCRATCH%/}/claude-panel"`.
- Every `gh pr` call carries `<n>` explicitly.

## Step 0: Preflight (one batched Bash call)

First, alone: `ps -p $$ >/dev/null 2>&1 || echo SANDBOXED`. Sandboxed → tell the user the panel needs unsandboxed Bash and stop.

Arg: PR number or URL (extract number); none → `gh pr view --json number -q .number`.

```bash
gh api 'repos/{owner}/{repo}/pulls/<n>' --jq '{state, draft, title, base: .base.ref, head: .head.ref, headSha: .head.sha, author: .user.login, mergeable_state, body, fork: (.head.repo.full_name != .base.repo.full_name)}'
gh api user -q .login
gh api 'repos/{owner}/{repo}/pulls/<n>/reviews' --paginate --jq '[.[] | {id, user: .user.login, state, commit_id, body}]'
gh api 'repos/{owner}/{repo}/pulls/<n>/comments' --paginate --jq '[.[] | select(.in_reply_to_id == null) | {user: .user.login, path, line, body}]'
gh api 'repos/{owner}/{repo}/issues/<n>/comments' --paginate --jq '[.[] | {user: .user.login, body}]'
grep "\"pr\":<n>," ~/.claude/claude-panel-runs.jsonl 2>/dev/null | tail -1
```

Pin `headSha` from REST (`gh pr` GraphQL caches stale heads). Then:

- Closed/merged → stop. Draft → ask.
- Last run log line has same `headSha` → already done for this head; ask before re-running. Different `headSha` → `git diff --name-only <old> <headSha> -- <PR paths>`: empty = rebase only, ask; non-empty = delta pass, pass those files as `focusFiles`.
- My own PENDING review → fetch its comments (`.../reviews/<id>/comments`) into the raised list.
- **Raised list**: one line per root thread / substantive review body / PR comment, any author (CodeRabbit, humans, me): `path:line — gist (author)`. Bot noise (CI summaries, walkthroughs) excluded.

## Step 1: Workspace

```bash
mkdir -p "$SCRATCH"
git fetch origin "<base>"
git fetch origin "refs/pull/<n>/head"            # separate fetch; combined breaks FETCH_HEAD
[ "$(git rev-parse FETCH_HEAD)" = "<headSha>" ] || echo "HEAD MOVED — re-pin"
```

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
    workdir: <absolute WORKDIR>, base, headSha, diffPath: <absolute>,
    raised: <raised list text, or "">,
    repoAgents: [<names>],
    escalate: <true if sensitive paths touched>,
    focusFiles: <delta files or null>,
    skipLenses: <e.g. ["tests"] for docs/config-only PRs, else []>
  }
})
```

Lenses: `correctness`, `security`, `conventions`, `tests` (Sonnet unless `escalate`), `skeptic` (session model, diff-only), plus each repo agent. All forced into one JSON schema. Then one merge agent (dedup + already-raised filter + neutral question per finding), then blind validators (≤4 findings/file-group, see only the neutral question; CONFIRMED needs a concrete reachable trigger). Repo-agent rule violations skip validation. Last, one skeptical adjudicator tags each surviving finding `action` fix / ticket / skip with `reason` (worth-it, not-worth-it, unrealistic, pattern-conflict, codebase-wide) and a `note`.

While it runs, don't poll — the completion notification wakes you. If it dies, re-invoke with `resumeFromRunId`; finished agents return cached.

## Step 2b: QA (UI PRs)

Start right after Step 2's Workflow call, so it runs alongside. Skip, and say
why in the report, when:

- `fork` is true: QA runs the PR's code locally. Only if the user asks
- No UI in the diff: no changed `.tsx`/`.jsx`/`.vue`/`.svelte`/`.css`/`.scss`
  outside tests and stories (`git -C "$WORKDIR" diff --name-only origin/<base>...<headSha>`)

Otherwise follow the `qa` skill from `WORKDIR` (already at `headSha`, so
committed): apps (each touched app plus its runtime deps: workers, queues,
realtime), flows, async triggers and data from the diff and intent; base
`origin/<base>`; `Code:` is `WORKDIR`. No QA desk running → QA is "skipped:
desk not running" in the report. Wait for the desk's verdict before Step 3;
don't poll, its message wakes you.

## Step 3: Report (local)

Re-pin head (`gh api .../pulls/<n> --jq .head.sha`). Moved → `git diff --name-only <reviewed> <new>`; mark findings in changed files "may be fixed/moved".

Print, in chat:

1. Banner (sensitive / large / conflicted / head moved), if any.
2. **Findings** (confirmed + codified), grouped by `action`, then severity, then confidence:
   - **Fix**: `**path:line** [sources · severity · conf] — claim` + one-line evidence + `fix` as a code block when present
   - **Ticket** (codebase-wide): same line + `note` (the pattern and where else it applies)
   - **Skip**: one line each with `reason` and `note`, so the user can override
3. **Uncertain** (major+ only, one-liners) — worth a human look.
4. **Refuted** — one line each with evidence, so the user can override.
5. Already on thread — one line each.
6. **QA** (Step 2b): verdict (`PASS`/`FAIL`/`BLOCKED`/skipped + why), its findings one line each with severity and evidence path, and its "Not tested" list. `BLOCKED` is never shown as a pass.
7. Agents: ran / out-of-scope / failed. Never present a failed agent as clean.
8. Verdict suggestion (would comment / approve / request changes) — advisory only.

Save the full workflow result to `$SCRATCH/pr-<n>-<headSha:0:8>.json`, and append one line to `~/.claude/claude-panel-runs.jsonl`:

```json
{"pr":<n>,"repo":"<owner/repo>","headSha":"...","date":"YYYY-MM-DD","agents":{"correctness":{"found":N,"confirmed":N},...}}
```

(per-source found vs confirmed — over time this is the hit rate for pruning/tuning lenses).

Completion ping: `osascript -e 'display notification "PR #<n>: <k> findings" with title "claude-panel"' 2>/dev/null`.

## Step 4: Follow-ups (ONLY when the user asks)

Offer in one line at the end: "Want a pending review, the checkbox ticked, or fixes applied?"

**Pending review** (invisible to others until the user submits in the UI):

- Comment body: the Conventional Comment itself (`**label (decorations):** subject`, then 1-3 declarative sentences of discussion), then a ` ```suggestion ` block when `fix` exactly replaces the anchored line range. No attribution header ("Claude said this", sources, finding ids), no blockquote wrapper.
- Be judicious: post only findings worth the author's time. Drop duplicates of open or declined threads, speculative questions, follow-up-only concerns (→ ticket), and nits CI/CodeRabbit already catches. Merge findings that share one fix.
- Only diff lines anchor; others go in the review body. Each comment stands alone.
- `gh api 'repos/{owner}/{repo}/pulls/<n>/reviews' --input payload.json` with `{body, commit_id, comments:[{path, line, side:"RIGHT", body}]}` and **no `event`**. Existing pending review of mine → append via GraphQL `addPullRequestReviewThread` instead (one pending review per user). Give the `html_url`.

**Tick the template checkbox** (re-fetch body first — author may have edited):

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

If a QA brief for this run is still with the desk, wait for its reply first: the tester reads code from `WORKDIR`. Then `git worktree remove` this run's `pr-<n>-<RUN>-wt` only (never the repo root), then `git worktree prune`. Mention other `claude-panel/pr-*-wt` leftovers; remove only on confirmation.
