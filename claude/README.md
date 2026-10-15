# Claude Code

My [Claude Code](https://claude.com/claude-code) config.

| Path                            | How it's loaded                                  | What                                     |
| ------------------------------- | ------------------------------------------------ | ---------------------------------------- |
| `CLAUDE.md`                     | linked to `~/.claude/CLAUDE.md`                  | Global instructions for every session    |
| `settings.json`                 | linked to `~/.claude/settings.json`              | Hooks, permissions, plugins, attribution |
| `plugin/`                       | live via `CLAUDE_CODE_PLUGIN_DIRS`               | My skills and agents (plugin `sjsimpson`) |
| `.claude-plugin/marketplace.json` | local marketplace `dotfiles` (`extraKnownMarketplaces`) | Third-party plugins I use          |

`settings.json` is the source of truth for what's installed: `enabledPlugins`
lists every plugin, and `install.sh` installs any that are missing.

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
- **Env**:
  - `CLAUDE_CODE_PLUGIN_DIRS`: loads `plugin/` and moshi straight from disk
  - `CAVEMAN_DEFAULT_MODE=manual`: caveman's plugin turns itself on every
    session by default; this keeps it off until `/caveman`
- **Hooks**:
  - Notification: macOS notification via `terminal-notifier`, only when the
    kitty window running Claude isn't focused (needs `jq`)
  - Session, prompt, and tool events: forwarded to
    [moshi](https://github.com/rjyo/moshi) (`moshi-hook`) for remote sessions

## Plugins

### Mine: `sjsimpson` (`plugin/`)

Loaded live from the folder, so edits apply on the next session with no
reinstall. Invoke as `/claude-panel` (or `/sjsimpson:claude-panel` if a name
ever clashes).

| Kind  | Name               | What                                                                    |
| ----- | ------------------ | ----------------------------------------------------------------------- |
| Skill | `claude-panel`     | PR review panel: parallel Claude reviewers with distinct lenses, blind validation, report in chat. Posts nothing unless asked |

To add a skill: `plugin/skills/<name>/SKILL.md`. Agent: `plugin/agents/<name>.md`.

### Third-party (`.claude-plugin/marketplace.json`)

| Plugin                    | Source                                                            | What                                                       |
| ------------------------- | ----------------------------------------------------------------- | ---------------------------------------------------------- |
| `caveman`                 | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | `caveman*` compressed output, `cavecrew` agents, plus `lean-build`, `surgical-patch`, `safe-refactor`, `migration`, `investigate-first`, `verify-and-stop` |
| `gh-stack`                | [github/gh-stack](https://github.com/github/gh-stack)             | Stacked PRs with the `gh stack` extension                  |
| `find-skills`             | [vercel-labs/skills](https://github.com/vercel-labs/skills)       | Search for and install skills                              |
| `vercel`, `rust-analyzer-lsp` | official marketplace                                          | Vercel platform tools; Rust LSP                            |

Repos that aren't Claude plugins themselves (gh-stack, find-skills) are
wrapped with `"strict": false` so their `skills/` folder loads as a plugin.

To add one:

1. Add an entry to `.claude-plugin/marketplace.json` (or use an existing marketplace)
2. Add `"<name>@dotfiles": true` to `enabledPlugins` in `settings.json`
3. Run `claude plugin marketplace update dotfiles && ./install.sh`
4. Add a row to the table above

`claude plugin details <name>@<marketplace>` shows what a plugin loads (skills,
agents, hooks) and its token cost.

## Related

- [`bin/gh-review`](../bin/gh-review): throwaway worktree for a PR;
  `gh-review --claude <pr>` opens Claude Code in it
- [herdr](https://herdr.dev): runs multiple Claude sessions side by side
