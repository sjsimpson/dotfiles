# Dotfiles

Public repo. Anything committed is world-readable.

## Never commit

- Secrets, tokens, PII (phone numbers, emails beyond git identity, addresses),
  or work specifics (org/repo names, internal IDs, label IDs)
- Personal values the dotfiles need → `~/env.zsh` (real file, not linked).
  Register them in `env_vars` in `install.sh`, which prompts for missing ones
  in the user's terminal. Read them at runtime; never hardcode or default them
- Personal values: point the user at `./install.sh` (it prompts)
- Machine-specific git → `~/.gitconfig.local`
- Plans, ideas, work notes → `~/notes` (private vault), not here

## Layout

- `./install.sh` applies everything and must stay safe to re-run. Every
  `config/<name>/` is auto-linked to `~/.config/<name>` (herdr: only
  `config.toml`); `launchd/*.plist` is copied, not linked
- New CLI tools go in the `Brewfile`
- `claude/plugin/` (skills, agents, MCP) loads live; keep it generic
- Docs are part of the change (candidate for global; revisit later): update the matching README table/section
  (`README.md`, `claude/README.md`, `config/*/README.md`) in the same commit

## Commits

- Before pushing, grep the unpushed diff for anything above
