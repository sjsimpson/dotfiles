# Report template

Every review/QA report (claude-panel, deep-review, qa-tester, the QA desk's
reply, stack summaries) uses these sections, in this order. Skip a section
that doesn't apply; never rename one. Files go under
`~/screenshots/<repo>/<branch>/` (branch `/` → `-`).

```
# <PR #n | branch> <review | status | QA>: <title>
Head <sha:8> · <YYYY-MM-DD> · <mode, inputs: panel / QA desk / prod data / ...>

## Verdict
<approve | request changes | comment> (status: mergeable now | needs X;
QA: PASS | FAIL | BLOCKED). One-paragraph why. Blocked → "Blocked on: <exactly
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

Chat-only reports (claude-panel) use the same section names and order as
headings or bold labels. Tool-specific extras (claude-panel's
Fix/Ticket/Skip groups, refuted findings, agents ran) go inside Findings or
after Not verified.
