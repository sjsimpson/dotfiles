# Specs: Linear issues and docs

How to write, edit, and audit a ticket or spec doc. Used by `spec-audit`,
`start-ticket`, and any agent creating or editing a ticket. Voice:
`voice.md`. Real examples (private, optional): `~/notes/work/specs-examples.md`
if it exists.

Specs live only in Linear issues and docs. Requirements also arrive from
threads, email, and meetings: those are **Sources**, and the spec must carry
what they decided.

## Shape

Issues. Skip a section that would be empty, except **Problem** and **Scope**.

- **Title**: the outcome, imperative, ≤70 chars. "Retry failed webhook
  deliveries", not "Webhook issue"
- **Problem**: prose, first person (`voice.md`): who hits it, what goes
  wrong, and why it matters. A few sentences; code names only where a
  builder needs them (1-3)
- **Scope**: checkboxes, each one checkable as written. Plain language;
  "must" is optional, for the criterion that can't bend, never on every line
- **Out of scope**: what a reader might assume is included but isn't
- **Accepted risks** (optional): known gaps we're shipping with, and why
- **Open questions**: numbered, each with an owner. `@name` notifies them in
  Linear; use a plain first name if it shouldn't
- **Sources**: links (threads, docs, PRs). Paraphrase; never paste message
  bodies or customer data

Docs (technical proposals etc.): sections can differ, but **Problem** and
**Open questions** are required, and Language, Edits, and Sources apply.

Made-up example:

```markdown
## Problem
When a partner's webhook endpoint blips, we lose their events for good:
`deliverWebhook` logs the 5xx and drops the payload. Partners then ask us
why their data is missing, and we can't replay it.

## Scope
- [ ] Failed deliveries retry 5 times with backoff (1m → 16m)
- [ ] After the last retry, the event shows as `failed` in the partner log
- [ ] Retries must never reorder events for the same partner

## Out of scope
- Manual replay UI (follow-up)

## Open questions
1. Do 4xx responses retry? (me)
```

## Language

Voice comes first (`voice.md`): it should read like I wrote it, not like
audit output. Within that:

- One term per concept, matching the code's names
- Concrete values: "5 retries, 1m → 16m", not "a few retries"
- Name the actor: "the worker retries", not "it is retried"
- A real branch says what happens on both sides
- Say whether a list is exhaustive when it matters ("only these 3 states")
- No hedges in scope: "something like…", "maybe", "not sure" go to **Open
  questions** with an owner

## Edits

- **Not started** (status before In Progress, no branch or PR): edit in place
- **Started**: don't rewrite. Append to the description:

  ```markdown
  ## Update MM-DD-YYYY
  <what changed> because <why>. <source link>
  ```

  Strike superseded criteria (`~~old~~`), don't delete them. Then post a
  one-line comment, `Spec updated: <summary>`, so subscribers get notified
- Comments count as part of the spec: read them before auditing or building

## Agent-created tickets

1. State the problem in 1-2 plain sentences; confirm the user understands
   and agrees
2. Draft it in this shape and run the **Audit flags** below on the draft
   (`spec-audit` when code is at hand); fix what you can
3. Show the draft plus anything still flagged
4. `save_issue` only after approval. Sub-issue of the originating ticket when
   there is one; link the origin either way

## Audit flags

The checklist lives in `spec-audit` §3.
