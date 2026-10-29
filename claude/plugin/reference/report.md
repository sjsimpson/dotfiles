# Report template

Every review/QA report (claude-panel, deep-review, qa-tester, the QA desk's
reply, stack summaries) uses these sections, in this order. Every claim
(finding, QA row) ends with `How tested: <ran X | read code | reasoned>`. Skip a section
that doesn't apply; never rename one. Files go under
`~/screenshots/<repo>/<branch>/` (branch `/` → `-`).

```
# <PR #n | branch> <review | status | QA>: <title>
Head <sha:8> · <YYYY-MM-DD> · <mode, inputs: panel / QA desk / prod data / ...>

## Verdict
<approve | request changes> (status: mergeable now | needs X;
QA: PASS | PARTIAL | FAIL | BLOCKED, with coverage: "7/9 scenarios run"),
then a one-paragraph why.
- **Harm test** (= blocking): a concrete trigger causes wrong behavior,
  data loss, wrong money/filings, a security hole, or a broken repo rule.
  The panel adjudicator's `blocking`; the same test for QA bugs. Severity
  is advisory; nits and style never block
- Any blocking finding or QA FAIL (= any blocking QA bug) → request
  changes; else approve. Never comment
- QA: PASS = every planned scenario ran; PARTIAL = some skipped, none
  blocking
- QA BLOCKED → no verdict and nothing to GitHub (no pending review sync);
  tell me in chat, "Blocked on: <exactly what's missing and how to provide
  it>", so we troubleshoot, then re-run

## Findings
Blocking first, most severe first; then non-blocking, one line each (my
PRs: fixed, with the commit; others': fixed in a nit commit, or kept
local). Each one a draft per `voice.md` → PR feedback:
### N. `path:line`
**label (decorations):** subject + 1-3 sentences. Evidence (repro steps,
screenshot path, log line). Suggestion block if exact. How tested.
QA bugs: `### N. <title>` with `**issue (blocking|non-blocking):**`, then
Steps (numbered, minimal) / Expected / Actual / Evidence (files) / Suspect
(`path:line`, only if grounded) / How tested

## Earlier asks
One line each, from `pr-threads`: `path:line — ask (author)`: resolved /
not / partly at head, with evidence. Re-runs: also each finding from the
earlier report: posted? resolved?

## QA
Per pass or app: mode (app | probe), verdict, coverage, evidence dir.
Probe: sandbox used and blast radius (what reads/triggers on the changed
files). Scenario table: scenario · ran? · result · evidence (How tested;
"reasoned" never backs a PASS row). Probe evidence in the dir: the run scripts and
shims, one transcript per run with the resulting state, grader outputs
plus a per-axis agreement table. Video only for app mode.
Sandbox: what's still live (scratch repo, files, processes) and awaits my
OK to tear down; "none" if all cleaned up

## Deeper coverage
PARTIAL/BLOCKED only. Per unrun scenario: `blocked` (needs X; how to
provide it) or `skipped` (why; cost to run), and how to get it

## Safety
Risky changes only: every path that can act for real, and its guards

## Not verified
Everything in scope you didn't verify, and why. A BLOCKED in-scope flow is
never a pass
```

## Pending review body

When findings go into a pending review (`pr-pending`), the review body
(`findings.json` `body`) follows `voice.md` → Review bodies: 1-3 sentences
in my voice, then any findings that can't anchor to a diff line (each per
`voice.md` → PR feedback). What was tested, prod checks included, stays in the
local report; at most one clause of it in the body.

No commit SHA (the run marker and ledger track the head). Internal IDs
only; no customer details, local paths, or tool names. Re-runs update it (`pr-pending` replaces only its own unedited body).

**Approve with no findings** (no anchored and no unanchored comments): just
approve, no body. `findings.json` gets `"body": ""` and no comments, so
`pr-pending` starts no review and clears its own earlier body, if any. The
Tested write-up stays in the local report. Exception: a pushed nit commit
(`deep-review` step 4) puts its one line in the body.

After a sync, chat gets the verdict, the pending review link, sync counts,
and a short summary (findings one line each); the full report stays in its
file.

Chat-only reports (claude-panel) use the same section names and order as
headings or bold labels. Tool-specific extras (claude-panel's
Fix/Ticket/Skip groups, refuted findings, agents ran) go inside Findings or
after Not verified.
