export const meta = {
  name: "claude-panel",
  description:
    "Claude-only PR review: parallel lens finders + repo reviewer agents, semantic merge, blind validation, skeptical adjudication",
  whenToUse:
    "Invoked by the claude-panel skill with preflight args; not for direct use",
  phases: [
    {
      title: "Find",
      detail: "lens finders + repo reviewer agents in parallel",
    },
    {
      title: "Merge",
      detail: "dedup across finders and against existing PR threads",
    },
    { title: "Validate", detail: "blind refutation, grouped by file" },
    {
      title: "Adjudicate",
      detail: "fix / ticket / skip: worth it, realistic, fits codebase patterns",
    },
  ],
};

// args: { number, title, intent, workdir, base, baseRef?, headSha, diffPath, raised, repoAgents: string[],
//         escalate: bool, focusFiles: string[] | null, skipLenses: string[] }

const SEVERITY = { type: "string", enum: ["blocker", "major", "minor", "nit"] };

const FINDINGS = {
  type: "object",
  properties: {
    inScope: {
      type: "boolean",
      description: "false if nothing in this diff is relevant to your focus",
    },
    findings: {
      type: "array",
      items: {
        type: "object",
        properties: {
          file: { type: "string" },
          line: {
            type: "integer",
            description: "line number in the head commit",
          },
          severity: SEVERITY,
          confidence: { type: "integer", minimum: 0, maximum: 100 },
          claim: { type: "string", description: "one falsifiable sentence" },
          detail: {
            type: "string",
            description: "why, 1-3 sentences, cite path:line evidence",
          },
          fix: {
            type: "string",
            description:
              "exact replacement code for the anchored line(s), or empty",
          },
        },
        required: ["file", "line", "severity", "confidence", "claim", "detail"],
      },
    },
  },
  required: ["inScope", "findings"],
};

const MERGED = {
  type: "object",
  properties: {
    findings: {
      type: "array",
      items: {
        type: "object",
        properties: {
          id: { type: "string" },
          file: { type: "string" },
          line: { type: "integer" },
          severity: SEVERITY,
          sources: { type: "array", items: { type: "string" } },
          claim: { type: "string" },
          detail: { type: "string" },
          fix: { type: "string" },
          question: {
            type: "string",
            description:
              "the claim restated as a neutral yes/no question about the code, with no reasoning or framing",
          },
          codified: {
            type: "boolean",
            description:
              'true only if raised by a repo reviewer agent citing a written rule, and not an environmental claim like "breaks the build"',
          },
        },
        required: [
          "id",
          "file",
          "line",
          "severity",
          "sources",
          "claim",
          "detail",
          "question",
          "codified",
        ],
      },
    },
    alreadyRaised: {
      type: "array",
      items: {
        type: "object",
        properties: {
          file: { type: "string" },
          line: { type: "integer" },
          gist: { type: "string" },
          sources: { type: "array", items: { type: "string" } },
        },
        required: ["file", "gist", "sources"],
      },
    },
  },
  required: ["findings", "alreadyRaised"],
};

const VERDICTS = {
  type: "object",
  properties: {
    verdicts: {
      type: "array",
      items: {
        type: "object",
        properties: {
          id: { type: "string" },
          verdict: {
            type: "string",
            enum: ["CONFIRMED", "REFUTED", "UNCERTAIN"],
          },
          line: {
            type: "integer",
            description: "corrected line in the head commit",
          },
          evidence: {
            type: "string",
            description: "one sentence, cite path:line",
          },
          confidence: { type: "integer", minimum: 0, maximum: 100 },
        },
        required: ["id", "verdict", "line", "evidence", "confidence"],
      },
    },
  },
  required: ["verdicts"],
};

const ADJUDICATED = {
  type: "object",
  properties: {
    decisions: {
      type: "array",
      items: {
        type: "object",
        properties: {
          id: { type: "string" },
          action: { type: "string", enum: ["fix", "ticket", "skip"] },
          reason: {
            type: "string",
            enum: [
              "worth-it",
              "not-worth-it",
              "unrealistic",
              "pattern-conflict",
              "codebase-wide",
            ],
          },
          note: {
            type: "string",
            description:
              "one sentence: the cost/benefit call; for pattern conflicts, the existing pattern with path:line and whether to follow it here or change it everywhere",
          },
        },
        required: ["id", "action", "reason", "note"],
      },
    },
  },
  required: ["decisions"],
};

const A = args;
// baseRef: any ref/SHA (stack layers diff against their parent); default origin/<base>
const BASE = A.baseRef || `origin/${A.base}`;
const finderModel = A.escalate ? undefined : "sonnet";

const LENSES = [
  {
    key: "correctness",
    model: finderModel,
    focus:
      "Logic bugs: edge cases, null/undefined, async ordering and races, off-by-one, wrong or swallowed error handling, callers broken by changed signatures or return shapes. Trace changed functions into their callers.",
  },
  {
    key: "security",
    model: finderModel,
    focus:
      "Authz/authn gaps, injection, secret or PII leakage (logs, errors, client bundles), data integrity, unsafe migrations, missing tenant scoping, unvalidated input crossing a trust boundary.",
  },
  {
    key: "conventions",
    model: finderModel,
    focus:
      "Violations of WRITTEN project rules only: CLAUDE.md, AGENTS.md, .coderabbit.yaml, and .claude/skills/patterns/ (read the sections relevant to touched areas). Every finding must quote or cite the rule it violates. Taste is not a finding.",
  },
  {
    key: "tests",
    model: finderModel,
    focus:
      "Missing tests that would let a real regression through; untested error paths; tests that cannot fail or pin incidental text instead of behavior. Search the whole test tree before claiming a gap. Not coverage percentage. Read-only: do not install deps or run tests.",
  },
  {
    key: "spec",
    model: finderModel,
    focus: `Compare the diff to the ticket spec below, not to code quality. Report: requirements the spec asks for that are missing or partial; behavior the diff adds that the spec didn't ask for (scope creep); requirements that look implemented but wrong. Quote the spec line in every finding.\n\nSpec:\n${A.spec || ""}`,
  },
  {
    key: "smells",
    model: finderModel,
    focus:
      "Design smells in added code, always judgement calls labeled 'possible <smell>': mysterious name, duplicated code across hunks, feature envy, data clumps, primitive obsession, repeated switches, shotgun surgery, divergent change, speculative generality, message chains, middle man. A written repo rule or the codebase's existing pattern overrides any smell. At most 3 findings, only ones a reviewer would ask to change in this PR.",
  },
  {
    key: "skeptic",
    model: undefined,
    focus: `Read ONLY the diff file and the PR intent — do not open other repo files. Ask: what is the single most likely way this change breaks in production? Report at most 3 findings, each one you would bet on. Your value is a different vantage point from the reviewers who read the full repo.`,
  },
].filter(
  (l) =>
    !(A.skipLenses || []).includes(l.key) && (l.key !== "spec" || A.spec),
);

const common = `PR #${A.number}: ${A.title}
Author intent:
${A.intent || "(none given)"}

Checkout (READ-ONLY — do not edit, install, run tests, commit, or delete anything): ${A.workdir}
Diff: \`git -C ${A.workdir} diff ${BASE}...${A.headSha}\` (saved at ${A.diffPath}).
${A.focusFiles && A.focusFiles.length ? `Delta pass — these files changed since the last review; weight them: ${A.focusFiles.join(", ")}\n` : ""}
Review ONLY lines this diff adds or changes. Before claiming something is missing, read the full file — the missing guard/handler/caller is usually just outside the hunk. Don't flag pre-existing code, things CI catches (types, lint, format), or work the PR intent says is deferred.
Already raised on the PR — do NOT re-report:
${A.raised || "none"}
Do not launch subagents. Fewer real findings beat many speculative ones. If nothing in the diff is relevant to your focus, return inScope=false with no findings.`;

const finders = [
  ...LENSES.map((l) => ({
    key: l.key,
    run: () =>
      agent(
        `You are the "${l.key}" reviewer on a PR review panel.\nFocus: ${l.focus}\n\n${common}`,
        {
          label: `find:${l.key}`,
          phase: "Find",
          schema: FINDINGS,
          model: l.model,
        },
      ),
  })),
  ...(A.repoAgents || []).map((name) => ({
    key: name,
    run: () =>
      agent(
        `Audit this PR per your instructions, then report each violation as a finding (severity blocker/major for rule violations, minor for needs-human-review items).\n\n${common}`,
        {
          label: `find:${name}`,
          phase: "Find",
          schema: FINDINGS,
          agentType: name,
          model: finderModel,
        },
      ),
  })),
];

phase("Find");
const results = await parallel(finders.map((f) => f.run));
const agents = finders.map((f, i) => ({
  key: f.key,
  status:
    results[i] == null ? "failed" : results[i].inScope ? "ok" : "out-of-scope",
  found: results[i] ? results[i].findings.length : 0,
}));
const raw = finders.flatMap((f, i) =>
  results[i] ? results[i].findings.map((x) => ({ ...x, source: f.key })) : [],
);
log(
  `${raw.length} raw findings from ${agents.filter((a) => a.status !== "failed").length}/${agents.length} agents`,
);

if (raw.length === 0)
  return {
    agents,
    confirmed: [],
    uncertain: [],
    refuted: [],
    alreadyRaised: [],
  };

phase("Merge");
const merged = await agent(
  `Merge these PR review findings. Repo reviewer agents: ${(A.repoAgents || []).join(", ") || "none"}.

1. Any finding that matches an already-raised thread (semantic match) goes to alreadyRaised, not findings.
2. Merge findings that describe the same underlying problem at the same place (semantic, not string match); union their sources, keep the highest severity, keep the clearest claim/detail/fix. When unsure whether two match, keep them separate.
3. Assign ids f1, f2, ...
4. For each, write \`question\`: the claim as a neutral yes/no question about the code, stripped of reasoning, severity and framing (e.g. "Does createX in a/b.ts:40 run without a companyId in its where clause?").
5. codified=true only for repo-reviewer-agent findings that cite a written rule and are not environmental ("won't compile", "breaks the build").
Do not judge validity — that happens next. Do not drop anything except already-raised matches.

Already raised on the PR:
${A.raised || "none"}

Findings (JSON):
${JSON.stringify(raw)}`,
  { label: "merge", phase: "Merge", schema: MERGED, effort: "medium" },
);

const toValidate = merged.findings.filter((f) => !f.codified);
const byFile = {};
for (const f of toValidate) (byFile[f.file] = byFile[f.file] || []).push(f);
const groups = Object.values(byFile).flatMap((fs) => {
  const out = [];
  for (let i = 0; i < fs.length; i += 4) out.push(fs.slice(i, i + 4));
  return out;
});

phase("Validate");
const verdictSets = await parallel(
  groups.map(
    (g, i) => () =>
      agent(
        `Each question below is about the code in the read-only checkout at ${A.workdir} (head ${A.headSha}; if the tree looks modified, read with \`git -C ${A.workdir} show ${A.headSha}:<path>\`). Diff base: ${BASE}.

Assume the implied problem is NOT real; try to prove that from the code. Read full files and callers/callees 1-2 levels deep, not just the diff. For test-gap questions, search the whole test tree for existing coverage. CONFIRMED only if the code shows the problem is real AND reachable: cite the concrete trigger (input, state, or caller path) in evidence. Possible-in-theory but unreachable from real callers is REFUTED; REFUTED if the code shows it isn't (or it is pre-existing / handled elsewhere); UNCERTAIN otherwise. Do not edit, install, or run anything.

${g.map((f) => `- id ${f.id} — ${f.file}:${f.line} — ${f.question}`).join("\n")}`,
        {
          label: `validate:${g[0].file.split("/").pop()}#${i}`,
          phase: "Validate",
          schema: VERDICTS,
        },
      ),
  ),
);

const verdicts = {};
verdictSets
  .filter(Boolean)
  .forEach((s) => s.verdicts.forEach((v) => (verdicts[v.id] = v)));

const confirmed = [],
  uncertain = [],
  refuted = [];
for (const f of merged.findings) {
  if (f.codified) {
    confirmed.push({
      ...f,
      verdict: "CODIFIED",
      confidence: 90,
      evidence: "repo reviewer rule violation",
    });
    continue;
  }
  const v = verdicts[f.id];
  if (!v) {
    uncertain.push({
      ...f,
      verdict: "UNVALIDATED",
      confidence: 0,
      evidence: "validator failed",
    });
    continue;
  }
  const out = {
    ...f,
    line: v.line || f.line,
    verdict: v.verdict,
    confidence: v.confidence,
    evidence: v.evidence,
  };
  if (v.verdict === "CONFIRMED") confirmed.push(out);
  else if (v.verdict === "REFUTED") refuted.push(out);
  else uncertain.push(out);
}
const rank = { blocker: 0, major: 1, minor: 2, nit: 3 };

// Real isn't the same as worth doing: one skeptical pass over what survived.
const toAdjudicate = [...confirmed, ...uncertain].filter(
  (f) => f.verdict !== "UNVALIDATED",
);
if (toAdjudicate.length) {
  phase("Adjudicate");
  const adj = await agent(
    `You are a skeptical tech lead deciding which validated review findings on PR #${A.number} are worth acting on. Read-only checkout: ${A.workdir} (head ${A.headSha}). Do not edit, install, or run anything.

For each finding choose:
- fix (reason worth-it): real, reachable, and the benefit clearly beats the churn
- skip, reason not-worth-it: churn or risk outweighs benefit (taste, micro-optimizations, nits on code about to change)
- skip, reason unrealistic: the trigger is implausible in practice, or the fix is impractical to execute in this PR
- pattern-conflict: the finding or its fix goes against how the codebase already does this. Grep for the existing pattern and cite it. If the pattern is fine, skip (follow the pattern here). If the pattern itself is the problem, choose ticket
- ticket, reason codebase-wide: a real improvement that belongs everywhere, not just in this PR; do it via a follow-up ticket (optionally fixed here first and propagated)

Push back by default: a finding earns "fix" only with a concrete trigger and a proportionate fix. Blockers with a confirmed trigger are fix unless the fix is impractical.

Findings (JSON):
${JSON.stringify(toAdjudicate.map(({ id, file, line, severity, claim, detail, fix, verdict, evidence }) => ({ id, file, line, severity, claim, detail, fix, verdict, evidence })))}`,
    { label: "adjudicate", phase: "Adjudicate", schema: ADJUDICATED },
  );
  const byId = {};
  (adj ? adj.decisions : []).forEach((d) => (byId[d.id] = d));
  for (const f of toAdjudicate) {
    const d = byId[f.id];
    if (d) Object.assign(f, { action: d.action, reason: d.reason, note: d.note });
  }
}
const sort = (xs) =>
  xs.sort(
    (a, b) =>
      rank[a.severity] - rank[b.severity] || b.confidence - a.confidence,
  );

return {
  agents,
  confirmed: sort(confirmed),
  uncertain: sort(uncertain),
  refuted,
  alreadyRaised: merged.alreadyRaised,
};
