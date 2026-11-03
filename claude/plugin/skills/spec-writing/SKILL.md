---
name: spec-writing
description: "Draft or rewrite a Linear issue or spec doc as me, per specs.md Shape, then trim it and run the voice pass. Returns the draft (or a diff/Update block for an existing ticket); saves nothing without my OK. Use for /spec-writing, when creating or editing a ticket or spec, or for spec-audit's proposed spec."
argument-hint: "<issue ID | doc URL | notes> [audit findings]"
---

# Spec writing

Turn what's known (notes, a thread, an existing ticket, `spec-audit`
findings and answers) into a spec I'd have written: short, checkable, in
my voice.

Rules: `specs.md` (Shape, Language, Edits) in
`<this skill's base directory>/../../reference/`, and its made-up example.
Read it first. Real models (private, optional):
`~/notes/work/specs-examples.md` → Models.

## 1. Inputs

Already loaded by the caller (`spec-audit`): use those, fetch nothing.

- Existing issue: `get_issue` + `list_comments`; started or not (specs.md
  Edits) decides draft vs `## Update` block. Doc: `get_document`
- Parent and linked sources: read them so the spec can **link** them
  instead of restating them
- From `spec-audit`: its findings and grill answers are inputs; the code
  evidence stays in the audit, not the spec

## 2. Draft

Fill specs.md Shape: Title, Problem, Scope, then only the optional
sections that have something real. Language rules apply line by line.

## 3. Trim

The draft has to fit this **budget**; cut until it does:

- **Problem**: 2-4 sentences. Who hits it, what goes wrong, why it
  matters. Context a parent ticket, thread, or code already holds gets a
  link, not a retelling
- **Scope**: one line per checkbox, one checkable outcome each (what QA
  would see), no rationale or implementation steps. Over ~7 items → say
  in one line it may need slicing (`spec-audit` §3 Slicing)
- **Out of scope / Accepted risks**: one line each
- **Open questions**: one line each, owner in parentheses
- No sentence that repeats another section, and no process narration
  ("we discussed", "after looking into it")

Done when every section is inside its budget.

## 4. Voice

Run the `voice` skill on the trimmed draft (surface: Linear issue or
doc). Take its rewrite.

## 5. Return

- New ticket or not-started edit: the full draft; for an edit, a diff
  against the current text
- Started ticket: the `## Update MM-DD-YYYY` block plus the
  `Spec updated: <summary>` comment (specs.md Edits)

Save to Linear (`save_issue` / `save_document`, then the comment) only on
my OK.
