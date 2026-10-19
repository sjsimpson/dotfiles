---
name: triage
description: Ranked "what needs me" brief across every configured source (issue tracker, PRs, calendar, error alerts, email, meeting notes, blocked Claude agents, personal tasks). Writes a dated brief to the assistant home and prints the short version. Read-only. Use when the user asks for a triage, brief, catch-up, or "what should I look at".
argument-hint: "[quick] (quick = chat only, no brief file)"
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
- The latest file in `briefs/`: so you can mark items **new** since then

No home or no Sources table: say so and stop.

## 2. Gather

Query every source in parallel (one message, many tool calls). Per source:

- Narrow window (default: last 24h for alerts, 3d for email, open items for
  PRs/issues)
- Metadata over bodies: titles, IDs, authors, states, links. Open a body only
  when you can't rank without it
- A source that fails or isn't connected: note it under **Gaps**, keep going

## 3. Rank

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
duplicates (a PR in both GitHub and the tracker is one item). Mark items new
since the last brief with 🆕.

End with **Focus**: the one thing to start next and the free calendar gap to
do it in.

## 4. Output

Each item, one line: `- [ID/title](link) · why it's here · suggested action`.
Follow the home's Rules on what may be written (links and titles only, no
bodies, PII, amounts, or secrets).

- Write `briefs/YYYY-MM-DD.md` (heading `# Brief YYYY-MM-DD`). If it exists,
  append `## HH:MM update` with only what changed. Skip with `quick`
- Print a short version in chat: **Now** and **Today** in full, counts for the
  rest, then **Focus**, then **Gaps**

## Never

Post, comment, merge, send, archive, label, mark read, or change status in
any source. Suggested actions are for the user.
