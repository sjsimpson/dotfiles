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

- PR feedback: the format in global `CLAUDE.md` (Conventional Comments)
- PR descriptions: short, about 10 lines of content. Follow the repo's
  template headings. Summary: 1-2 sentences on what changed and why, then
  the ticket and design links on one line. Testing and risk: 2-3 sentences
  (what I tested, the risk, prod impact). Reviewer notes: only the
  template's checkboxes. No per-flow walkthroughs, "not covered" lists, or
  extra notes; detailed QA and review results stay in the local report
- Commits: Conventional Commits, ticket ID as scope (global `CLAUDE.md`)
- Pending review body: `report.md` → Pending review body
- Linear issues and docs: `specs.md`
