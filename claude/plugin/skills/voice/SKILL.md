---
name: voice
description: "Final pass on any draft written as me (Linear, PR text, review bodies, Basecamp, email): check it against voice.md and rewrite what fails. Returns the revised draft; posts nothing. Use for /voice, or as the last step before showing any draft written as me."
argument-hint: "[surface] <draft text | file path>"
---

# Voice pass

Make a draft read like I typed it myself. Rewrite only; never post or save.

Rules: `<this skill's base directory>/../../reference/voice.md`, the whole
file plus the section for this draft's surface (Per surface). Real samples
(private, optional): `~/notes/work/specs-examples.md` → Voice samples.
Read both first.

## 1. Surface

The surface the caller or argument names; else infer it from the draft
(ticket, PR description, review body, comment, check-in). Its section in
`voice.md` sets the length and shape.

## 2. Check

Go line by line. A line fails when it:

- Reads like **audit output**: labels (`Verdict:`, `Priorities:`), arrow
  chains, fragment bullets carrying what should be prose, tool names
- Hedges, fills, or signs off ("just", "I think maybe", "Hope this helps")
- Restates what a link, parent ticket, or earlier section already says
- Spends more words than the point needs: two sentences where one
  carries it, a list of one
- Bolds more than the one thing nobody can miss
- Uses a relative date ("Friday") or an unnamed actor ("it gets retried")
- Pastes a message body, log, or customer data instead of linking

Done when every line has passed or been marked.

## 3. Rewrite

Rewrite each marked line in first person, point first, then the why.
Keep every fact, number, code name, link, and `@mention` verbatim. Add no
new claims. Normal prose, whatever style the session uses (`voice.md`:
drafts are persisted text).

## 4. Return

The revised draft, then one line: what changed and why (e.g. "Cut the
restated parent context; Problem 7 → 3 sentences"). No changes needed →
say so and return the draft unchanged.
