---
name: start-ticket
description: "Start work on a Linear ticket: herdr worktree on its branch, a Claude agent in it, spec-audit + grilling first so questions surface before code. Writes nothing to Linear or GitHub. Use for /start-ticket or \"start ENG-1234\"."
argument-hint: "<ticket ID | issue URL> [repo] [extra context]"
---

# Start ticket

Set up a worktree and agent for a ticket; the agent audits the spec first.
You dispatch and relay. Never edit code here, and never write to Linear or
GitHub (status moves on its own once a branch is pushed).

## 1. Gather

- `get_issue`: title, status, team, `gitBranchName`, parent, linked
  PRs/branches. Done or canceled → stop and say so
- Repo: the argument, else the current repo (`gh repo view --json
  nameWithOwner`), else ask. Checkout = that repo's main worktree
- Agent name = ticket lowercased (`eng-1234`); taken → `agent-lifecycle.md`
  → Start (plugin `reference/`)
- Reply-to: this session's name (`ListAgents`)

## 2. Worktree + agent

```bash
git -C <checkout> fetch -q origin
git -C <checkout> worktree list --porcelain   # branch already checked out?
```

- Branch checked out in a worktree → use it (new tab there:
  `herdr tab create --workspace <id> --cwd <path> --label "<ticket>"`)
- Branch exists (local or `origin/<branch>`) → worktree on it, then
  fast-forward it (`agent-lifecycle.md` → Start)
- Else → new branch from the default branch:

```bash
HERDR_ENV=1 herdr worktree create --cwd <checkout> --branch <gitBranchName> \
  --base origin/<default branch> --label "<ticket>" --no-focus
herdr-sort   # new worktree appends below reviews; move it into the projects
herdr agent start <agent> --kind claude --pane <pane> -- -n <agent>
herdr agent prompt <agent> "<brief>"
herdr agent wait <agent> --until working --timeout 60000
```

## 3. Brief

```
Task from the user (via <reply-to>): start <ticket> "<title>" in <repo>.
Worktree on branch <branch>. <extra context, if any>

1. Run the repo's normal worktree setup.
2. /sjsimpson:spec-audit <ticket>. Show the user the full output in this
   pane; message <reply-to> the audit log ping only.
3. Stop. Grill the questions with the user here (spec-audit step 5) until
   none are open, before writing code. Apply spec changes to Linear only
   when they say so.
4. Then build per the user's global rules (WIP commit first, gh stack for
   big changes). Code done → /sjsimpson:deep-review --fix (includes qa),
   then report. Never push or open a PR unless asked.
5. Then follow ~/.dotfiles/claude/plugin/reference/agent-lifecycle.md →
   Handoff and Done.
```

## 4. Report

Tell the user: agent name, worktree label, branch, and that the agent
grills them in its own pane. Its messages here are log pings, blockers, or
done (→ `agent-lifecycle.md` → Cleanup). Assistant home: log
`- <date>: <ticket> started: herdr worktree "<ticket>", agent \`<agent>\``.
