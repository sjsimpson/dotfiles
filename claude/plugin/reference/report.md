# Report template

Every review/QA report (claude-panel, deep-review, qa-tester, the QA desk's
reply, stack summaries) uses these sections, in this order. Skip a section
that doesn't apply; never rename one. Files go under
`~/screenshots/<repo>/<branch>/` (branch `/` → `-`).

```
# <PR #n | branch> <review | status | QA>: <title>
Head <sha:8> · <YYYY-MM-DD> · <mode, inputs: panel / QA desk / prod data / ...>

## Verdict
<approve | request changes> (status: mergeable now | needs X;
QA: PASS | FAIL | BLOCKED). Never comment: any `(blocking)` finding or QA
FAIL → request changes, else approve. QA BLOCKED → no verdict and nothing
to GitHub (no pending review sync); tell me in chat what's blocked so we
troubleshoot, then re-run. One-paragraph why. Blocked → "Blocked on: <exactly
what's missing and how to provide it>"

## Findings
Most severe first. Each one a draft per the global PR feedback rule:
### N. `path:line`
**label (decorations):** subject + 1-3 sentences. Evidence (repro steps,
screenshot path, log line). Suggestion block if exact.
QA bugs: `### N. <title>` with `**issue (blocking|non-blocking):**`, then
Steps (numbered, minimal) / Expected / Actual / Evidence (files) / Suspect
(`path:line`, only if grounded)

## Earlier asks
One line each, from `pr-threads`: `path:line — ask (author)`: resolved /
not / partly at head, with evidence. Re-runs: also each finding from the
earlier report: posted? resolved?

## QA
Per pass or app: PASS | FAIL | BLOCKED, scenarios run, evidence dir.
Passed scenarios one line each

## Safety
Risky changes only: every path that can act for real, and its guards

## Not verified
Everything in scope you didn't verify, and why. A BLOCKED in-scope flow is
never a pass
```

## Pending review body

When findings go into a pending review (`pr-pending`), the review body
(`findings.json` `body`) is in my voice (`voice.md`), like "2 nits, but
otherwise looks reasonable".

```
<verdict in one line: "Okay to merge, 2 nits" | "Don't merge yet: <why>">

Tested:
- Prod (read-only): <what I looked at and why, what it showed, what that
  means for the change>, one bullet per check
- Locally: <setup (e.g. prod-shaped data)>, then the flows and edge cases
  I ran and how each went; group passing ones, give steps for anything odd
- Didn't test <what>, only if it matters

<findings that can't anchor to a diff line, each per the PR feedback rule>
```

No bold "Tested" header, no commit SHA (the run marker and ledger track
the head). Internal IDs only; no customer details, local paths, or tool
names. Re-runs update it (`pr-pending` replaces only its own unedited body).

After a sync, chat gets the verdict, the pending review link, sync counts,
and a short summary (findings one line each); the full report stays in its
file.

Chat-only reports (claude-panel) use the same section names and order as
headings or bold labels. Tool-specific extras (claude-panel's
Fix/Ticket/Skip groups, refuted findings, agents ran) go inside Findings or
after Not verified.
