---
name: voice
description: "Final pass on any draft written as me (Linear, PR text, review bodies, Basecamp, email): check it against voice.md and rewrite what fails. Returns the revised draft; posts nothing. Use for /voice, or as the last step before showing any draft written as me."
argument-hint: "[surface] <draft text | file path>"
---

# Voice pass

Make a draft read like I typed it myself. Rewrite only; never post or save.

Rules: `<this skill's base directory>/../../reference/voice.md`: **Core**
plus the section for this draft's surface (Per surface). Read only those.

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

Done when every line has passed or been marked.

## 3. Rewrite

Rewrite each marked line in first person, as the surface's section shows.
Keep every fact, number, code name, link, and `@mention` verbatim. Add no
new claims. Normal prose, whatever style the session uses (`voice.md`:
drafts are persisted text).

## 4. Return

The revised draft, then one line: what changed and why (e.g. "Cut the
restated parent context; Problem 7 → 3 sentences"). No changes needed →
say so and return the draft unchanged.
