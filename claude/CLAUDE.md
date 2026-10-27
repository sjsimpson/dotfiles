# Global Claude Instructions

- [IMPORTANT] In all interactions and commit messages, be extremely concise and sacrifice
  grammar for the sake of concision. Except drafts written as me (plugin
  `reference/voice.md`): normal prose.

## Project CLAUDE.md

- When reading or writing a project's CLAUDE.md, pitch rules worth adopting
  globally (one line each + why) for my review. Never edit this file without
  my approval

## File Path Preferences

- Use relative paths from the project root instead of `~/` or absolute paths when working within a project
- This avoids filepath errors and is cleaner for project-based operations
- Example: Use `domains/transaction/src/mutations/file.ts` instead of `~/code/project/domains/transaction/src/mutations/file.ts`

## Plans

- [IMPORTANT] All plans should be extremely concise and sacrifice grammar for
  the sake of concision
- When presenting a plan, copy a link to the plan to my clipboard
- At the end of each plan, give me a list of unresolved questions to answer, if
  any

## Coding

- Before making any changes, commit any existing work as `WIP: <name>`, e.g.
  `WIP: snapshot before refactor`. Deliberately NOT Conventional Commits, so it
  must be reworded/squashed before merge
- Comments: none by default. Add only when asked, or when code is surprising /
  a workaround the next engineer would misread or "fix". Intent, rationale,
  review context → PR/commit, not comments. Unsure → leave out, mention in chat
- Before writing or reviewing code, load the repo's conventions skills (e.g.
  `patterns`) and read the sections the change touches

## Scope

- Edit only the repo/worktree this session works in (plus scratchpad,
  `~/screenshots`). Change needed elsewhere → `SendMessage` the session
  working there (`ListAgents`); none running → tell me the exact change.
  Never edit, then hand off
- Exception: the `dotfiles` session (`~/.dotfiles`) also owns my
  environment: `~/.config`, `~/.claude`, `~/env.zsh`, and the config side of
  `~/notes`: `assistant/CLAUDE.md`, `personal/dotfiles/`. The `assistant`
  session (`~/notes/assistant`) owns all other `~/notes` content
- Edits = source/config changes. Tool side effects (DB writes, caches, dev
  server files, QA desk worktree switches) are fine

## Git

- [IMPORTANT] Do not make comments, update pull requests, or push code changes unless
  I explicitly ask you to.
  - Pending reviews: only on others' PRs I review. `/deep-review` and
    `claude-panel` add findings via `pr-pending` without asking (never
    submit), and always report them locally too
  - My own PRs: no pending review. Report findings and offer to fix them
  - Public comments/replies/submits: draft locally (as
    `address-pr-comments` does), post only when I ask
- [IMPORTANT] Always use (except `WIP:` commits) [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for commit messages:
  `type(scope): subject` (types: feat, fix, refactor, test, chore, docs, perf,
  build, ci, style, revert). Ticket ID as scope when known, e.g.
  `feat(ENG-6659): add supported locations page`
- Comments should be shown locally for me to review and post
- [IMPORTANT] PR feedback (findings, drafts, posted comments) is the one
  format every skill and agent uses:
  - [Conventional Comments](https://conventionalcomments.org/):
    `**label (decorations):** subject`, then 1-3 sentences; ` ```suggestion `
    block when it exactly replaces the anchored lines; `file:line` in drafts
  - Posted: the comment only. No "Claude said this" / attribution header, no
    blockquote wrapper
  - Judicious: only what's worth the author's time. Drop duplicates of open
    or declined threads, speculative questions, follow-up-only concerns
    (→ ticket), nits CI/bots catch. Merge findings that share one fix
  - Existing feedback: `pr-threads <pr>` (threads with status, reviews,
    comments, my pending review)
- Writing/editing a Linear issue or doc → plugin `reference/specs.md`;
  anything written as me → `reference/voice.md`. Show the draft before
  `save_issue`
- Big changes: one gh stack of small reviewable PRs. Only the bottom PR is
  ready for review; upper layers stay drafts. Merge one layer at a time:
  `gh stack rebase` → `gh stack push` → CI green → `gh stack merge
  <bottom-pr> --yes`. Never merge the whole stack at once
  - Before opening a layer: `gh stack sync` → `/deep-review <pr> --fix` →
    report; I open it
  - Rebase stack branches only with `gh stack sync|rebase`, never plain
    `git rebase` (stale saved base; recovery: plugin `reference/gh-stack.md`)
- Stage explicit paths (`git add <paths>`), never `-A`/`.`: I often have
  unrelated uncommitted changes

## Secrets

- Never ask me to paste secrets or personal values (keys, tokens, phone
  numbers) into chat; chat is logged. Point me to a local file or a prompt I
  run in my terminal

## Playwright

- For in-app/browser testing, use the `qa` skill: you brief the repo's QA
  desk (`/qa-desk`), which sets up the main worktree and runs `qa-tester`.
  Playwright only loads inside `qa-tester`
- UI change → commit (WIP ok), run the `qa` skill before saying done, report
  its verdict
- A repo's main worktree belongs to its QA desk while one runs: never switch
  branches or edit there; work in a linked worktree
- Screenshots/videos: absolute `filename` under
  `$HOME/screenshots/<repo>/<branch>/` (branch `/` → `-`). Relative names land
  in the repo; paths outside `~/screenshots` are rejected
- Video: navigate first, then `browser_start_video` (starting on a blank page
  records nothing)
