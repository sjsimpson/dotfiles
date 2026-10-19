# Global Claude Instructions

- [IMPORTANT] In all interactions and commit messages, be extremely concise and sacrifice
  grammar for the sake of concision.

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

## Git

- [IMPORTANT] Do not make comments, update pull requests, or push code changes unless
  I explicitly ask you to.
- [IMPORTANT] Always use (except `WIP:` commits) [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for commit messages:
  `type(scope): subject` (types: feat, fix, refactor, test, chore, docs, perf,
  build, ci, style, revert). Ticket ID as scope when known, e.g.
  `feat(ENG-6659): add supported locations page`
- Comments should be shown locally for me to review and post
- [IMPORTANT] Always use [Conventional Comments](https://conventionalcomments.org/) when giving PR feedback

## Playwright

- Screenshots/videos: absolute `filename` under
  `$HOME/screenshots/<repo>/<branch>/` (branch `/` → `-`). Relative names land
  in the repo; paths outside `~/screenshots` are rejected
- Video: navigate first, then `browser_start_video` (starting on a blank page
  records nothing)
