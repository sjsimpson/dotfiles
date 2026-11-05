---
name: spec-audit
description: Audit a Linear issue or doc against the code before building it, then grill the open questions. Terminal only; posts nothing unless asked. Use for /spec-audit, or as step 1 of start-ticket, in a worktree of the repo the ticket changes.
argument-hint: "<linear issue ID | issue URL | doc URL>"
---

# Spec audit

Find what's wrong or missing in a spec before anyone builds it. Read-only:
no code edits, no Linear writes unless the user asks.

Rules: `voice.md` → **Core** and **Linear** (Shape, Language, Edits) in
`<this skill's base directory>/../../reference/`, plus §3 below. Read them
first.

## 1. Load the spec

- Issue: `get_issue` (description, status, parent, sub-issues, attachments,
  linked PRs/branches) + `list_comments`. Comments and `## Update` sections
  are part of the spec
- Doc: `get_document`
- Linked sources (threads, docs, meeting notes): open the ones you can reach;
  note the ones you can't under **Not checked**
- Parent and sibling issues: titles + status, to see what's already split
  out
- Started or not (Linear → Edits): decides how the spec diff gets applied

## 2. Ground in the code

Spawn one `Explore` subagent (`model: "sonnet"`) to map the code the spec
touches; your context keeps its report, not the file reads. Brief it with
the spec's claims as a list and the repo's conventions skills (e.g.
`patterns`) to load. Its report: per claim, the real names, call sites,
data shapes, and existing behavior, each fact with `file:line`, plus what
it couldn't find. Before a finding or question rests on a fact, read its
cited lines yourself; a fact you didn't check goes in as "per explore".

## 3. Checklist

One pass, in this order. Each finding: what, where (spec line and
`file:line`), why it matters, proposed fix.

1. **Conflict with code**: spec assumes behavior, names, or data the code
   doesn't have; scope that breaks an existing caller; terms that differ
   from the code's
2. **Source drift**: a requirement in a linked source the spec is missing or
   contradicts
3. **Ambiguity**: hedges, unnamed actors, ifs without elses, lists not marked
   exhaustive, vague values
4. **Edge and failure cases**: empty/zero, duplicates, retries, partial
   failure, concurrency, permissions, flag on/off, existing data that
   doesn't fit
5. **Risk**: money, filings, external systems, migrations, irreversible
   writes. Name the guard the spec needs
6. **Testability**: each criterion checkable as written? How would QA see it?
7. **Slicing**: does it fit one reviewable PR? If not, a gh-stack split
   per `gh-stack.md` → Slicing (bottom layer first, one line each)

Skip a lens with nothing real to say. Only flag what would change the build
or the review; drop style nits.

## 4. Output (terminal only)

1. **Verdict**: ready to build / ready after the questions / needs rework,
   one line why
2. **Findings**: one plain sentence each, then its `file:line` evidence.
   Every conflict-with-code finding, always. The rest: top ~5 by impact,
   then "N more on request"
3. **Proposed spec**: the `spec-writing` skill's output, given the current
   spec and these findings. Shown as a diff against the current text, or
   (started ticket) its `## Update` block plus the one-line update comment
4. **Questions**: numbered, each with who should answer
5. **Not checked**: unreachable sources, code you couldn't find

## 5. Grill

Questions the user owns → run them through the `grilling` skill's rounds
(round 1 = those questions), each round asked via AskUserQuestion per
global CLAUDE.md → Questions to me, not as a chat list. After each round, rerun `spec-writing` with the
answers folded in and rerun the checklist on what changed: an answer can open a
new conflict or edge case, which feeds the next round. Questions others own
stay in the spec's **Open questions** and never block a round. Done when the
frontier is empty: print the final spec diff and verdict.

Then offer in one line to apply the diff to Linear; apply it per Linear →
Edits only on the user's OK.
