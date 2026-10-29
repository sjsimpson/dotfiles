# My voice

Rules for anything written as me: Linear issues and comments, PR
descriptions and replies, review bodies, Basecamp posts and check-ins, email.

**Drafts are persisted text.** Write them in normal prose, never terse,
compressed, or caveman, whatever style the session uses. Only the chat
around the draft stays terse.

- First person, conversational. Short/casual to friendly-professional, with
  a little warmth
- Lead with the point, then the why. Explain the why; that's what readers
  act on
- Prose for problems and context. Bullets only for real lists (checklists,
  steps, 3+ parallel items)
- A few key code names in backticks, where a reader needs them. Link, don't
  paste
- Emphasis only where it matters (**bold** the one thing nobody can miss)
- Unambiguous dates: "10/31 might slip", not "Friday might slip"
- No filler, hedging, sign-offs, AI attribution, or blockquote wrappers
- After others have read it, change by appending (`## Update MM-DD-YYYY`),
  not rewriting

## Before / after

Made-up examples. Real ones (private, optional):
`~/notes/work/specs-examples.md` → Voice samples.

Ticket problem. Not this:

> - `syncInvoices` (`billing/sync.ts:88`) must skip archived accounts
> - Archived → no sync; else → sync
> - `archivedAt` must be checked before `fetchInvoices`

This:

> I keep seeing invoice syncs run for archived accounts, which burns API
> quota and sometimes fails loudly at 2am. Let's have `syncInvoices` skip
> anything with `archivedAt` set before it fetches.

Review body. Not this: "Verdict: approve. 2 nits. QA pass. No blocking."
This: "Looks good to me! Two small nits, nothing blocking. I clicked
through the new filters locally and they behaved."

Check-in. Not this: "Priorities: ENG-1234 (in review), ENG-1240 (blocked:
API keys)." This: "Mostly heads-down on webhook retries this week. ENG-1234
is up for review if anyone has a minute. I'm waiting on API keys for
ENG-1240, so @Sam, could you nudge that along?"

## Per surface

- PR feedback: **PR feedback** below
- PR descriptions: see **PR descriptions** below
- Commits: Conventional Commits, ticket ID as scope (global `CLAUDE.md`)
- Review bodies (approve, comment, request changes): **Review bodies**
  below; the pending-review mechanics are in `report.md`
- Linear issues and docs: `specs.md`

## PR feedback

Findings, drafts, and posted comments, every skill and agent:

- [Conventional Comments](https://conventionalcomments.org/):
  `**label (decorations):** subject`, then 1-3 sentences in my voice; a
  ` ```suggestion ` block when it exactly replaces the anchored lines;
  `file:line` in drafts
- Posted: the comment only, nothing around it
- Blocking or not, never in between: every posted comment is decorated
  `(blocking)` or `(non-blocking)` (blocking per `report.md` → Verdict).
  Others' PRs: post only the blocking ones. Mechanical nits get fixed and
  pushed on my OK (`deep-review` step 4), plus one line in the review body;
  the rest stay in the local report. Nits never hold up a PR
- Judicious: only what's worth the author's time. Drop duplicates of open
  or declined threads, speculative questions, follow-up-only concerns
  (→ ticket), nits CI/bots catch. Merge findings that share one fix

## PR descriptions

Title: per global `CLAUDE.md` (the repo's CI title check wins, never
Conventional Commits). Body: short, about 10-15 lines of content under the
repo's template headings.
Each section mixes a short text block with a bulleted list where items are
parallel and worth scanning. Text only when it adds context; otherwise
terse-ish.

- **Summary**: 1-2 sentences on what changed and why. Bullets for the
  distinct changes when there are 2+. Ticket and design links on one line.
  When the shape of the change is easier to see than to read, add the
  smallest visual that shows it: a short `diff` sketch of a call tree,
  component tree, or file tree, or a small Mermaid diagram. One at most
- **Testing and risk reduction**: a sentence on the risk and prod impact,
  saying whether it's a one-way door (hard to roll back: migrations,
  external writes, deletes) or a two-way door, and what it could break
  (blast radius). Then bullets for what I tested
- **Notes for reviewers**: the template's checkboxes, plus a bullet only
  for something a reviewer must know
- No per-flow walkthroughs, "not covered" lists, or extra notes. Detailed
  QA and review results stay in the local report
- **Screenshots/video** (UI changes): annotated by default, so a reviewer
  gets the point without context. Pair them when possible: an uncropped
  context shot with the changed area outlined, so the reader knows where
  to find it, then a crop of that area (2x) with each row or element
  labeled by the data state behind it and what changed outlined (before
  vs after where it helps). One annotated pair beats several raw shots.
  1-3 critical-path images inline; anything else worth including (edge
  cases, error states) goes below them in one collapsible,
  `<details><summary>More screenshots (N)</summary>`, with a blank line
  after `</summary>` so the markdown renders. Sources and output in
  `~/screenshots/<repo>/<branch>/` (`annotated-<name>.png`). Added once
  the PR exists (`gh pr create` can't attach). Reference each file in the
  body by the path you attach, then from that dir:
  `gh pr edit <n> -R <owner/repo> --body-file body.md --attach ./after.png`.
  `--attach` uploads and rewrites `![alt](./after.png)` to the hosted URL;
  check `gh pr view <n> --json body` shows `user-attachments` URLs
- **Annotating**: a one-off Pillow script in the scratchpad,
  `uv run --with pillow python3 annotate.py in.png out.png` (no ImageMagick
  on macOS). Outline on the full shot; for the crop: crop box, 2x resize,
  labels or a side panel, a colored outline on the changed element. Fonts:
  `/System/Library/Fonts/HelveticaNeue.ttc` (index 1 = bold)

Made-up example:

```markdown
## Summary
Failed webhook deliveries now retry instead of being dropped, so partners
stop losing events when their endpoint blips.
- Retries 5 times with backoff (1m → 16m)
- Exhausted events show as `failed` in the partner log

ENG-1234 · [Design](https://example.com/design)

## Testing and risk reduction
Low risk: only touches the delivery worker, behind `webhook_retries`.
- Unit tests for backoff and ordering
- Local: forced 500s, saw 5 retries then `failed`

![Partner log with a failed event](./after.png)

## Notes for reviewers
- [x] Tests added
```

## Review bodies

What I'd say if I typed it myself: 1-3 sentences, plus bullets only for
findings that can't anchor to a line. The inline comments carry the
details; the body never repeats them.

- **Approve, no findings**: no body (`report.md`)
- **Approve with nits**: say it's fine and the nits don't block. "Looks
  good! A couple of small nits inline, nothing blocking."
- **Request changes**: lead with the blocker and why, then point at the
  comments. "Holding off for now: retries can reorder events for the same
  partner (comment on `deliver.ts`). Everything else looks good."
- **Comment** (questions, no verdict): the question or context in a
  sentence or two
- Testing: one clause, only when it adds confidence or shows the failure
  ("Clicked through it locally with prod-shaped data"). Never a "Tested:"
  list of passing flows, a prod/local breakdown, verdict labels, or tool
  names. The full write-up stays in the local report
