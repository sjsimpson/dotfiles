# Stack (`--stack`)

Layers from the PR's base chain, open PRs only:

```bash
gh pr list -R <owner/repo> --head <base> --state open --json number,headRefName,baseRefName   # parent; repeat down to the default branch
gh pr list -R <owner/repo> --base <head> --state open --json number,headRefName               # child; repeat up. Several → ask which
```

- Bottom → top. One layer → plain run. More than 4 → state the count and
  ask (each layer is a full panel + QA)
- `--fix` doesn't combine: fix the checked-out layer, then the next after
  the user opens it (`gh-stack.md` → Flow per layer)
- Per layer: steps 1-4 as above (herdr), own worktree, agent and report,
  brief with the stack line. Dispatch all at once; the QA desk queues their
  QA. Others' stack: sync each layer's pending review as it reports
- Track the layers; each agent's message wakes you. When all are in (or
  blocked), write `$HOME/screenshots/<repo>/stack-<bottom head>/stack-review.md`
  as the shared report: Verdict per layer + overall; Findings merged across
  layers (same problem twice → one item, owned by its owner layer per
  `address-pr-comments`; fixes that cascade to upper layers noted); Earlier
  asks, QA, Not verified as links to each layer's report
- My own stack → offer `/address-pr-comments stack` with the layer reports
  and the summary
