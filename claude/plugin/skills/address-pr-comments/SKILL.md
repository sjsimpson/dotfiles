---
name: address-pr-comments
description: "Triage and fix review feedback on my own PR or gh stack (human/bot threads + claude-panel findings): a fix / ticket / skip / reply decision table I approve, then fixes in the owner layer, bottom up. Use to address, resolve, or work through PR comments or review findings."
argument-hint: "[pr-number | pr-url | stack] [panel result .json ...]"
---

# Address PR comments

Feedback in, approved changes out, in the right branch, with a paper trail.

## Rules

- **Your PRs only.** The PR author must be `gh api user -q .login`; otherwise stop
- **Gate before changing anything.** Edits, commits, and ticket writes happen
  only after the user approves the decision table (Step 3). Approval covers
  exactly what's in the table
- **Never push** (`git push`, `gh stack push|submit|sync`) and never resolve
  threads or re-request review unless asked. Draft replies are shown
  locally; post them only when the user asks
- **Ticket paper trail.** Spec changes follow `reference/specs.md`
  (`<this skill's base directory>/../../reference/`) Edits:
  a started ticket gets an appended `## Update MM-DD-YYYY` (strike, don't
  delete) plus a `Spec updated:` comment; never rewrite the title or edit
  existing comments. Progress notes (not spec changes) are plain dated
  comments
- Follow the user's global git rules (WIP commit of existing work first,
  Conventional Commits with the ticket ID as scope)

## Step 0: Scope

Arg: PR number/URL, `stack`, or none (current branch). Then:

```bash
gh api user -q .login
gh stack view --json 2>/dev/null   # exit 2 = not a stack: single-PR mode
git status --porcelain
```

- **Layers**: stack mode = `branches[]` bottom to top (skip `isMerged`); single
  mode = the one branch. For each: name, head, parent (previous layer or
  trunk), PR number if `pr` exists
- **Commit mode**: if *no* layer has a PR yet (unsubmitted stack) → `fixup`
  (fold fixes into the commit that introduced the code). Otherwise →
  `commit` (new commits on the owning branch)
- **Ticket**: from the branch name or PR title (`ENG-1234`-style), per layer
- Dirty tree → WIP commit per the global rule on the current branch, or ask if
  that branch isn't part of the stack

## Step 1: Collect feedback

Per layer with a PR, unresolved only:

```bash
pr-threads <pr> --json   # threads (isResolved/isOutdated), reviews, PR comments, full bodies
```

Plus any claude-panel results passed in (result `.json` files or findings
already in this conversation). Panel findings arrive pre-tagged with
`action`/`reason`/`note`; keep their call unless thread context changes it.

Drop: resolved threads, bot walkthroughs/CI summaries, comments by the user
that aren't requests, outdated threads whose code is gone. One item per
distinct request: `id · source (author) · layer · path:line · ask`.

## Step 2: Decide (skeptically)

Treat every item as suspect, including humans and the panel. Read the code
around each `path:line` before deciding.

| Action | When |
|---|---|
| **fix** | Real, reachable (name the trigger), and the fix is proportionate |
| **skip · not-worth-it** | Churn or risk outweighs benefit; taste; nit on code about to change |
| **skip · unrealistic** | Implausible trigger, or impractical to execute in this PR |
| **pattern-conflict** | Request or fix goes against how the codebase already does it. Grep and cite the pattern (`path:line`). Weigh changing it *here only* (inconsistency) vs *everywhere* (scope). Usually: follow the pattern here → skip; pattern is wrong → ticket |
| **ticket · codebase-wide** | Real improvement that belongs everywhere. Optionally fix here first, then propagate via ticket |
| **reply** | A question or discussion, not a code change; draft an answer |

**Holistic pass** across all layers: merge duplicates (same problem raised on
several PRs), and spot fixes that cascade (a signature change in layer 1 that
upper layers call).

**Owner layer** for each fix: the lowest layer that introduced the code.

```bash
git blame -L <line>,<line> <layer-branch> -- <path>   # introducing commit
git branch --contains <sha>                            # lowest stack branch containing it = owner
```

If the right fix belongs lower than where it was raised (a shared helper from
layer 1 misused in layer 3), the owner is the lower layer. In `fixup` mode,
also record the target commit SHA (must be in the owner's
`parent..branch` range; otherwise plain commit).

## Step 3: Decision table → wait

Print, grouped by layer bottom to top:

```
Layer 1 · eng-1234-foo · PR #101 · mode: commit
| id | from | path:line | ask | action · reason | plan (owner / commit target) |
```

Then **Skips** (one line each with the reason, so the user can override),
**Tickets** (existing ticket to comment on, or new sub-issue under which
parent), **Draft replies** (`voice.md` → PR feedback), and the verification
commands you'll run. Stop and wait. The user may approve all, edit actions, or
approve per layer.

## Step 4: Apply, bottom up

For each layer with approved fixes, lowest first:

1. `gh stack checkout <branch>` (single mode: `git checkout <branch>`)
2. Edit. Keep each fix minimal and in this layer's concern
3. Verify on this branch: the repo's typecheck/lint/tests for touched packages
   (find commands in CLAUDE.md, AGENTS.md, or `package.json` scripts; scope to
   affected packages/files). Failing → fix or stop and report; never commit red
4. Commit:
   - `fixup`: `git commit --fixup=<target-sha>` per fix, then
     `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <parent>` on this branch
   - `commit`: `git commit -m "fix(<TICKET>): <what changed>"`, one per logical
     fix (group trivial ones)
5. `gh stack rebase --upstack`. Conflicts: resolve if mechanical (`git add`,
   `gh stack rebase --continue`); otherwise `gh stack rebase --abort` and stop
   with the conflict summary
6. Upper layers touched by the cascade: re-run their typecheck before moving up

Return to the original branch (`gh stack top` or the starting branch) at the
end.

Then, per layer that got a commit, bottom up: work the ready checklist
again (plugin `reference/ready-checklist.md`; the new commit cleared it).

## Step 5: Tickets

Linear, for approved ticket items:

- **Existing ticket fits** (the layer's ticket, or one found via search):
  scope change → specs.md Edits (description update + `Spec updated:`
  comment); otherwise `save_comment` with `**Update MM-DD-YYYY:**` + what
  and why + PR link
- **Otherwise**: `save_issue` as a sub-issue (`parentId` = the layer's ticket,
  same team), title = the improvement, description = pattern, where it
  applies (`path:line` list), origin PR link, shaped per `reference/specs.md`.
  No edits to the parent's description
- Scope changed in this pass → update the layer's ticket per specs.md Edits
  (e.g., "fixed X here; propagation tracked in ENG-1240")
- All ticket text in `reference/voice.md`'s voice

## Step 6: Report

- Per layer: commits (SHA · subject), verification result, ready checklist
  (all checked, or the open items)
- Tickets: created/commented, with links
- Skipped: reason each
- Draft replies: ready to paste, per thread URL
- Not done: push (`gh stack push` / `gh stack submit`) and posting replies,
  waiting on the user. Offer them in one line
