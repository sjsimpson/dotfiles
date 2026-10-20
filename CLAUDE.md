# Dotfiles

Public repo. Anything committed is world-readable.

## Never commit

- Secrets, tokens, PII (phone numbers, emails beyond git identity, addresses),
  or work specifics (org/repo names, internal IDs, label IDs)
- Personal values the dotfiles need → `~/env.zsh` (real file, not linked).
  Register them in `env_vars` in `install.sh`, which prompts for missing ones
  in the user's terminal. Read them at runtime; never hardcode or default them
- Don't ask the user to paste personal values into chat; point them at
  `./install.sh` (it prompts) instead
- Machine-specific git → `~/.gitconfig.local`
- Plans, ideas, work notes → `~/notes` (private vault), not here

## Commits

- Stage explicit paths (`git add <paths>`), never `-A`/`.`: the user often has
  unrelated uncommitted changes
- Before pushing, grep the unpushed diff for anything above
