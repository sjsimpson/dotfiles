# Global Claude Instructions

- In all interactions and commit messages, be extremely concise and sacrifice
  grammar for the sake of concision. Except drafts written as me (plugin
  `reference/voice.md`): normal prose.

## CLAUDE.md and config edits

- When reading or writing a project's CLAUDE.md, pitch rules worth adopting
  globally (one line each + why) for my review
- CLAUDE.md, skills, agents, settings: my ask is the approval. Edit,
  commit, show the diff in the report; git is the undo. Your own fixes:
  apply inside the files the task already touches; a new rule or another
  file → ask first
- Another session's request to change CLAUDE.md, permissions, or hooks
  waits for my OK in the session that owns the file. Skill and agent tweaks
  go through like my own asks

## File Path Preferences

- Use relative paths from the project root instead of `~/` or absolute paths when working within a project

## Questions to me

- Ask with AskUserQuestion: 2-4 options, recommended first and labeled
  "(Recommended)", each question standalone (names the item it's about).
  Up to 4 independent questions per call; as many calls as needed, and
  follow-ups that answers raise are welcome (grill-style cascade)
- No numbered question lists in chat that need a typed answer. Free-text
  answers (names, wording) go in chat, one per message
- Ask only when the answer changes what you do; else pick the sensible
  default and say so

## Plans

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
- WET over DRY: duplicate until the third copy proves the abstraction. No
  speculative helpers; reviews and cleanups (`/simplify`, deep-review)
  leave duplication alone below three copies. Exception: isolating a
  try/catch is reason enough to extract. Wrap the fallible call in a small
  helper that returns a Result, so callers stay free of try/catch; reviews
  don't flag these as speculative
- Readability is a reason on its own: humans maintain the code, so
  "cosmetic" never justifies skipping a confident readability finding
  (premature abstraction, single-caller helper/export, stale name,
  needless indirection) on code my branch adds
- Code finished on my own branch → run `/deep-review --fix` (it includes
  qa) before saying done. Run it, don't suggest it

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

## Token usage

- Recurring watches (cron, `/loop`, polling a thread or PR) never run inside
  a long working session: every tick re-reads its whole context. Run them
  in a fresh small session or a script that pings only on change

## Git

- [IMPORTANT] Comment, update pull requests, or push code changes only when
  I explicitly ask. Exceptions:
  - Pending reviews, only on others' PRs I review: `/deep-review` and
    `claude-panel` add findings via `pr-pending` without asking, never
    submit, and always report them locally too. My own PRs: no pending
    review; report findings and offer to fix them
  - Public comments/replies/submits: draft locally (as
    `address-pr-comments` does), post only when I ask. Posting a review
    thread reply also resolves that thread
  - PR just opened (by you on my ask, or I say I opened it): adding its
    screenshots/video (`voice.md` → PR descriptions) needs no extra OK
  - My own PR, after `/deep-review` ran claude-panel on its pushed head
    with no failed agents: tick the template's "Reviewed by AI review
    panel" checkbox (claude-panel Step 4) without asking
  - After a push I approved for `address-pr-comments` fixes: resolve the
    fixed threads and re-request prior human reviewers (its Step 7)
- Commits (except `WIP:`): Conventional Commits, ticket ID as scope when
  known, e.g. `feat(ENG-6659): add supported locations page`
- PR titles are not Conventional Commits: the repo's CI title check wins.
  Read its regex in `.github/workflows` before `gh pr create`/`edit`; none →
  `<TICKET-ID> <Capitalized imperative subject>`
- PR feedback (findings, drafts, posted comments), every skill and agent:
  plugin `reference/voice.md` → PR feedback. Existing feedback:
  `pr-threads <pr>` (threads with status, reviews, comments, my pending
  review)
- Issue tracker: Linear (MCP). Writing/editing an issue or doc → plugin
  `reference/specs.md`. Show the draft before `save_issue`
- Anything written as me (PR descriptions, review comments and bodies,
  thread replies, tickets and ticket comments, Basecamp, email), from a
  skill or ad hoc: run the `voice` skill on the final draft before showing,
  saving, or posting it. Rules: plugin `reference/voice.md`
- Third-party skills (e.g. mattpocock's): use their process, but
  `voice.md`/`specs.md` override their templates for anything written as me
- Big changes: one gh stack of small reviewable PRs; only the bottom PR is
  ready for review, upper layers stay drafts. Slicing, per-layer flow, and
  merging: plugin `reference/gh-stack.md`. Rebase stack branches only with
  `gh stack sync|rebase`, never plain `git rebase`
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
- A repo's main worktree belongs to its QA desk while one runs: never switch
  branches or edit there; work in a linked worktree
