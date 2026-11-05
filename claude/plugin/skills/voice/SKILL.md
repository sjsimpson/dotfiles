---
name: voice
description: "Final pass on any draft written as me (Linear, PR text, review bodies, Basecamp, email): check it against voice.md and rewrite what fails. Returns the revised draft; posts nothing. Use for /voice, or as the last step before showing any draft written as me."
argument-hint: "[surface] <draft text | file path>"
---

# Voice pass

Make a draft read like I typed it myself. Rewrite only; never post or save.

Rules: `<this skill's base directory>/../../reference/voice.md`: the
intro, **Core**, and the section(s) for this draft's surface (Per surface).
Read only those: `grep -n '^## '` on that file for the line numbers, then
Read from line 1 through the end of Core, and each surface section from
its heading to the next `## ` (its `###` subsections included). A batch
spanning surfaces (review body + comments) reads each one.

## 1. Surface

The surface the caller or argument names; else infer it from the draft
(ticket, PR description, review body, comment, check-in). Its section in
`voice.md` sets the length and shape.

## 2. Check

Go line by line. A line fails when it:

- Reads like **audit output**: labels (`Verdict:`, `Priorities:`,
  `Why:`), tables, prod numbers, arrow chains, tool names, a "because"
  crammed into a fragment bullet
- Reads like **AI polish**: em dashes, benefit framing ("This ensures…",
  "…so X stays in control"), parallel full-sentence bullets, settled
  verdicts where I'd ask ("Thoughts?") or hedge honestly
- Fills or signs off beyond the surface's own ("Hope this helps", "Let me
  know if you have any questions!")
- Is longer than the surface allows, or than the point needs: two
  sentences where one carries it, a list of one, every template section
  filled for a small change
- Bolds for emphasis where my voice would use an ALL-CAPS word or "!!"
- Is impersonal where I'd say "I"/"we" or name a teammate
- Uses a relative date ("Friday") or an unnamed actor ("it gets retried")
- Pastes a message body, log, or customer data instead of linking

Surface checks (fail the draft, not just a line):

- **PR description**: Summary ends with the links line, the Linear ticket
  as a link (`[ENG-1234](https://linear.app/…)`; a bare ID fails); any stack
  info ("part of stack", "stacked on #…") fails; sections filled beyond
  what the diff needs fail
- **Review comment**: a label without a `(blocking)`/`(non-blocking)`
  decoration, or `nitpick`, fails
- **Reply on my PR**: bullets led by a `Topic:` label fail; a reply that
  answers several threads at once fails (one reply per thread)

Done when every line has passed or been marked.

## 3. Rewrite

Rewrite each marked line in first person, as the surface's section shows.
Keep every fact, number, code name, link, and `@mention` verbatim. The
draft's content is fixed: rewrite only what's there, adding no claims,
thanks, praise, "!!", or ALL-CAPS it doesn't already have. Core's warmth
describes how I phrase things, not material to insert. Normal prose, whatever style the session uses (`voice.md`:
drafts are persisted text).

## 4. Return

Several drafts in one call (a review's comments and body, a batch of
replies): one pass, each returned in place, same order and keys, so the
caller can write them back (e.g. into `findings.json`).

The revised draft, then one line: what changed and why (e.g. "Cut the
restated parent context; Problem 7 → 3 sentences"). No changes needed →
say so and return the draft unchanged.
