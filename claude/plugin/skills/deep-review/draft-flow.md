# Draft flow (`--draft`)

In-session only, my own branch or stack layer. One local pass, then the
draft PR on GitHub holds every finding (my pending review, CodeRabbit,
CI), so later reviews read them back through `pr-threads`. Fixes come
after, through `address-pr-comments`, when I ask.

1. Simplify: `fix-loop.md` step 1
2. Review + QA on local HEAD, as 3b (`claude-panel --local`, qa both
   passes). One round; findings go to step 3 as they are. QA `BLOCKED` →
   write the report with the blocker, stop, tell me
3. Report (shared template, report path from SKILL.md step 1 with `-draft`), plus
   `<report dir>/pr-<n>-findings.json` (no PR yet: `<n>` = branch name;
   SKILL.md step 3 brief → Deliverable shape) holding every `fix` and
   `ticket` finding and every QA bug, blocking or not; lines outside the
   diff go in the body. Skip, Uncertain and Refuted stay in the report. Bodies per `voice.md`
   → PR feedback; one `voice` skill pass over the body and all comments
4. Ask once (AskUserQuestion): push and open the draft? On OK, in order:
   - Push: `git push -u origin HEAD` (stack: `gh stack push`). No PR yet
     → `gh pr create --draft` (stack: `gh stack submit --draft`): title per
     the repo's CI title regex, body per `voice.md` → PR descriptions,
     `voice` skill pass
   - CodeRabbit: `.coderabbit.yaml` in the repo root → `gh pr comment <n>
     --body "@coderabbitai full review"`. None → skip, say so
   - Pending review: the `pr-pending sync` command in SKILL.md step 4
     (its ledger path and `--run` id). Never submit
   - Checkbox: the panel round had no failed agents → tick it (claude-panel
     Step 4 → Tick the template checkbox)
   - Watcher: `agent-lifecycle.md` → Watch (`--as author`)
5. Tell me: PR link, pending review counts and link, CodeRabbit triggered
   or skipped. I edit and submit the review in GitHub. Leaving draft:
   `reference/ready-checklist.md` → Ready
