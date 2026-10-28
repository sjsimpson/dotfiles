---
name: start-ticket
description: Start work on a Linear ticket - herdr worktree on the ticket's branch, a Claude agent in it, and spec-audit as the agent's first step, so questions surface before any code. Writes nothing to Linear or GitHub. Use when the user asks for /start-ticket or says "start ENG-1234" (the assistant dispatches it this way).
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
- Agent name = ticket lowercased (`eng-1234`). `ListAgents` already shows it
  → the ticket is started: tell the user, offer to message that agent, stop
- Reply-to: this session's name (`ListAgents`)

## 2. Worktree + agent

```bash
git -C <checkout> fetch -q origin
git -C <checkout> worktree list --porcelain   # branch already checked out?
```

- Branch checked out in a worktree → use it (new tab there:
  `herdr tab create --workspace <id> --cwd <path> --label "<ticket>"`)
- Branch exists (local or `origin/<branch>`) → worktree on it
- Else → new branch from the default branch:

```bash
HERDR_ENV=1 herdr worktree create --cwd <checkout> --branch <gitBranchName> \
  --base origin/<default branch> --label "<ticket>" --no-focus
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
   pane, and message <reply-to> the verdict + numbered questions.
3. Stop. Wait for the user's answers here before writing code. Apply spec
   changes to Linear only when they say so.
4. Then build per the user's global rules (WIP commit first, gh stack for
   big changes). Code done → /sjsimpson:deep-review --fix (includes qa),
   then report. Never push or open a PR unless asked.
```

## 4. Report

Tell the user: agent name, worktree label, branch, and that the audit
questions will come to this session. Assistant home: log
`- <date>: <ticket> started: herdr worktree "<ticket>", agent \`<agent>\``.
