---
name: triage
description: Ranked "what needs me" brief across every configured source (issue tracker, PRs, calendar, error alerts, email, meeting notes, blocked Claude agents, personal tasks). Writes a dated brief to the assistant home and prints the short version. Read-only. Use when the user asks for a triage, brief, catch-up, or "what should I look at".
argument-hint: "[quick] [personal] (quick = changes first + compact list, no brief file; personal = personal tasks only)"
---

# Triage

Gather everything that might need the user, rank it, write a brief. Never act
on anything you find.

## 1. Load config

Assistant home: `$ASSISTANT_HOME`, else `~/notes/assistant`. Read:

- `CLAUDE.md`: the **Sources** table (what to query, IDs, filters) and the
  **Rules** (what may be written to the brief). Sources and identifiers come
  only from there; this skill stays generic
- `priorities.md`: used for ranking
- The latest file in `briefs/` and its last timestamp (the `_HH:MM_` line or
  last `## HH:MM update` heading): the cutoff for 🆕
- `snoozed.md`, if present: one line per item,
  `- <ID or URL> · until YYYY-MM-DD · reason · added YYYY-MM-DD`

No home or no Sources table: say so and stop.

**`personal`** (weekends, or on request): use only the Personal source. Skip
work sources entirely; don't list them under Gaps.

## 2. Gather

Query every source in parallel (one message, many tool calls). Per source:

- Narrow window (default: last 24h for alerts, 3d for email, open items for
  PRs/issues)
- Metadata over bodies: titles, IDs, authors, states, links. Open a body only
  when you can't rank without it
- A source that fails or isn't connected: note it under **Gaps**, keep going

## 3. Snoozes

An item matching a `snoozed.md` line (by ID or URL) is hidden until its
`until` date, unless it has new activity since the snooze was written
(comment, review, status change, new event after `added`): then show it, marked
`⏰ woke early: <what>`. No `until` means 3 business days after `added`. Expired lines get removed when the brief is written (not in
`quick`).

The user snoozes in chat ("snooze X", "snooze X until Friday"); write the line
with the resolved `until` (default 3 business days), reason, and today as
`added`.

## 4. Rank

Buckets, in order:

1. **Now**: others blocked on the user (review requests, questions addressed to
   them), Claude agents `blocked`, production alerts that are new/regressed
   and plausibly theirs, meetings starting within 1h
2. **Today**: approved PRs to merge, review feedback on their PRs, failing
   checks, meetings today (with prep links), items in `priorities.md`, due/
   high-priority personal tasks
3. **Soon**: assigned issues not started, overdue project updates, tomorrow's
   meetings needing prep
4. **FYI**: status changes, others' updates, noise worth knowing exists

Within a bucket: priorities.md match > waiting longest > newest. Collapse
duplicates (a PR in both GitHub and the tracker is one item). 🆕 = created or
last active after the last brief's timestamp. Never use unread state (Linear
notifications are never marked read, so unread means nothing).

End with **Focus**: the one thing to start next and the free calendar gap to
do it in.

## 5. Output

Each item, one line: `- [ID/title](link) · why it's here · suggested action`.
Follow the home's Rules on what may be written (links and titles only, no
bodies, PII, amounts, or secrets).

- Write `briefs/YYYY-MM-DD.md` (heading `# Brief YYYY-MM-DD`, then a
  `_HH:MM_` line, plus ` · personal` in that mode). If it exists, append `## HH:MM update` with only what
  changed. Then prune expired `snoozed.md` lines
- Print a short version in chat: **Now** and **Today** in full, counts for the
  rest, then **Focus**, then **Gaps**

**`quick`**: same gathering and ranking, no file writes. Print:

1. **Changed since HH:MM** (last brief's timestamp): 🆕 and ⏰ items first
2. Everything else, compact and ranked: Now/Today one line each; Soon/FYI as
   one line or a count per group
3. **Focus**, then **Gaps**

## Never

Post, comment, merge, send, archive, label, mark read, or change status in
any source. Suggested actions are for the user.
