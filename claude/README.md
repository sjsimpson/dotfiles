# Claude Code

My [Claude Code](https://claude.com/claude-code) config. `install.sh` links
each file and skill dir into `~/.claude/` individually, never whole
directories, because other tools install into `~/.claude/skills` and
`~/.claude/agents` too.

| File            | Linked to                 | What                                   |
| --------------- | ------------------------- | -------------------------------------- |
| `CLAUDE.md`     | `~/.claude/CLAUDE.md`     | Global instructions for every session  |
| `settings.json` | `~/.claude/settings.json` | Hooks, permissions, plugins, attribution |
| `agents/*.md`   | `~/.claude/agents/`       | Custom subagents                       |
| `skills/*/`     | `~/.claude/skills/`       | Custom skills                          |
| `skills.txt`    | (read by `install.sh --skills`) | Third-party skills to install    |

## CLAUDE.md

Global rules, in short:

- Be terse, including in commits and plans
- Plans end with a list of open questions
- Commit existing work as `WIP: <name>` before making changes. That format is
  deliberately not Conventional Commits, so it has to be squashed before merge
- All other commits use Conventional Commits, with the ticket ID as scope
  (`feat(ENG-1234): …`)
- Never push, comment, or update PRs unless asked. Review comments use
  Conventional Comments and are shown locally first

## settings.json

- **Permissions**: `auto` mode
- **Attribution**: off for commits and PRs (no `Co-Authored-By` or session links)
- **Plugins**: `rust-analyzer-lsp`, `vercel` (official marketplace); moshi via
  `CLAUDE_CODE_PLUGIN_DIRS`
- **Hooks**:
  - Notification: macOS notification via `terminal-notifier`, only when the
    kitty window running Claude isn't focused (needs `jq`)
  - Session, prompt, and tool events: forwarded to
    [moshi](https://github.com/rjyo/moshi) (`moshi-hook`) for remote sessions

## Skills

Mine (in `skills/`):

| Skill           | What                                                                 |
| --------------- | -------------------------------------------------------------------- |
| `/claude-panel` | PR review panel: parallel Claude reviewers with distinct lenses, blind validation, report in chat. Posts nothing unless asked |

Third-party (listed in `skills.txt`, installed with `install.sh --skills` via
[`npx skills`](https://github.com/vercel-labs/skills)):

| Source                                                    | Skills                                                        |
| --------------------------------------------------------- | ------------------------------------------------------------- |
| [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | `caveman*` (compressed output, commits, reviews), `cavecrew`, plus `lean-build`, `surgical-patch`, `safe-refactor`, `migration`, `investigate-first`, `verify-and-stop` |
| [vercel-labs/skills](https://github.com/vercel-labs/skills) | `find-skills`: search for and install skills                |
| [github/gh-stack](https://github.com/github/gh-stack)     | `gh-stack`: stacked PRs with the `gh stack` extension         |

When you add a skill with `npx skills add`, add it to `skills.txt` and this
table too.

## Related

- [`bin/gh-review`](../bin/gh-review): throwaway worktree for a PR;
  `gh-review --claude <pr>` opens Claude Code in it
- [herdr](https://herdr.dev): runs multiple Claude sessions side by side
