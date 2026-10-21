# Global Claude Instructions

- [IMPORTANT] In all interactions and commit messages, be extremely concise and sacrifice
  grammar for the sake of concision.

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

## Scope

- Edit only the repo/worktree this session works in (plus scratchpad,
  `~/screenshots`). Change needed elsewhere → `SendMessage` the session
  working there (`ListAgents`); none running → tell me the exact change.
  Never edit, then hand off
- Exception: the `dotfiles` session (`~/.dotfiles`) also owns my
  environment: `~/notes`, `~/.config`, `~/.claude`, `~/env.zsh`
- Edits = source/config changes. Tool side effects (DB writes, caches, dev
  server files, QA desk worktree switches) are fine

## Git

- [IMPORTANT] Do not make comments, update pull requests, or push code changes unless
  I explicitly ask you to.
- [IMPORTANT] Always use (except `WIP:` commits) [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for commit messages:
  `type(scope): subject` (types: feat, fix, refactor, test, chore, docs, perf,
  build, ci, style, revert). Ticket ID as scope when known, e.g.
  `feat(ENG-6659): add supported locations page`
- Comments should be shown locally for me to review and post
- [IMPORTANT] Always use [Conventional Comments](https://conventionalcomments.org/) when giving PR feedback
  - Posted GitHub comments are the Conventional Comment only: no "Claude said this" / attribution header, no blockquote wrapper
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
