---
name: review-pr
description: Review a GitHub PR against project standards. Use when asked to review a PR by number or URL.
disable-model-invocation: true
context: fork
---

Review PR $ARGUMENTS.

## Gather context

1. `gh pr view <n> --json title,body,author,files,additions,deletions`
2. `gh pr diff <n>`
3. `gh pr checks <n>` — if CI is red, report that first and stop.
4. Read each changed file in full, not just the hunks.
5. Grep for call sites of any changed function signature or exported symbol.

## Evaluate

Against CLAUDE.md conventions, plus:

- Error and edge paths: null/empty/boundary, partial failure, retries
- Concurrency: shared mutable state, races, ordering assumptions
- Data: migration reversibility, index coverage, N+1 queries
- Security: authz on new endpoints, injection, secrets, PII in logs
- Tests: which new branches are uncovered — name them specifically
- Consistency: does this match how the codebase already solves this problem?

## Output

### Blocking

Only things that are wrong. file:line, what breaks, and the input that breaks it.

### Worth a look

Ambiguous — explain the tradeoff, don't prescribe.

### Nits

One line each. Max five. Prefer zero.

### Not evaluated

What you could not assess and why: missing domain context, unclear intent,
external system behavior, product decisions. Be specific — this is the
human reviewer's reading list.

Do not comment on style a formatter handles. Do not restate what the diff does.
If the PR is clean, say so in one sentence.
