---
name: review-stack
description: Review a whole gh stack with claude-panel (one run per layer), judge findings together, then hand off to address-pr-comments.
disable-model-invocation: true
argument-hint: "(none: the current stack)"
---

# Review stack

claude-panel on every layer, judged as one body of work, fixed bottom up.

Reviews are read-only and run in parallel. Fixes are sequential and
bottom up, owned by `/address-pr-comments`.

## Step 0: Stack

```bash
gh api user -q .login
gh stack view --json      # exit 2 = not a stack: use /claude-panel instead
git rev-parse --show-toplevel
```

Layers = `branches[]` not `isMerged`, bottom to top. For each: `name`, `head`,
parent ref (previous layer's branch, or `origin/<trunk>` for the bottom),
`pr.number` if any. `needsRebase` on any layer → tell the user (`gh stack
rebase`) and stop; reviewing stale layers wastes the run.

**Cost check**: each layer is one panel workflow (~8-12 agents). More than 4
layers → state the count and ask before running.

## Step 1: Prepare each layer

Read the claude-panel skill (`../claude-panel/SKILL.md`) for its rules, banner
flags, and the args contract. For each layer, in one Bash call:

```bash
SCRATCH="${TMPDIR:-/tmp}"; SCRATCH="${SCRATCH%/}/claude-panel"; mkdir -p "$SCRATCH"; RUN=$(date +%Y%m%d-%H%M%S)
git fetch origin <trunk>
git worktree add --detach "$SCRATCH/stack-<branch>-$RUN-wt" <head>
git diff <parentRef>...<head> > "$SCRATCH/stack-<branch>.diff"
```

- `intent`: PR body if a PR exists, else the layer's commit messages
  (`git log --format='%s%n%b' <parentRef>..<head>`)
- `raised`: for layers with PRs, the raised list exactly as claude-panel Step 0
  builds it; else ""
- `repoAgents`, `escalate` (sensitive paths), `skipLenses`: as claude-panel
- Empty diff → skip the layer

## Step 2: Run the panels

Invoking this skill is the user's opt-in to the workflows. Launch one Workflow
per layer, all in one message:

```
Workflow({ scriptPath: "<claude-panel skill dir>/panel.workflow.js",
  args: { number: <pr or 0>, title: <PR title or branch>, intent, workdir: <layer worktree>,
          base: <parent branch name>, baseRef: <parentRef>, headSha: <head>,
          diffPath, raised, repoAgents, escalate, focusFiles: null, skipLenses } })
```

Don't poll; completion notifications wake you. A failed run: re-invoke with
`resumeFromRunId`. Save each result to `$SCRATCH/stack-<branch>-<head:0:8>.json`.

## Step 3: Judge holistically

Across all layers' results plus the existing PR threads:

- **Same problem, several layers** → one item, owned by its owner layer (`address-pr-comments`) — the lowest layer that
  introduced the code (an upper layer often re-flags code it only calls)
- **Cascades**: a fix in layer N that changes what N+1.. rely on → note it on
  the item so the upper layers get re-verified
- **Re-check the panel's calls**: keep its fix/ticket/skip unless the
  stack-wide view changes it (e.g., an "inconsistent with codebase" finding
  that later layers establish as the new pattern)

## Step 4: Hand off

Follow `/address-pr-comments` (read `../address-pr-comments/SKILL.md`) in
`stack` mode, passing the result files and your holistic notes. Its decision
table is the user's gate; nothing changes before approval.

## Step 5: Cleanup

Remove this run's `stack-*-<RUN>-wt` worktrees (`git worktree remove`), then
`git worktree prune`.
