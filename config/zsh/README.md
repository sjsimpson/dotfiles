# zsh

`.zshrc` lives at the repo root (linked to `~/.zshrc`); the files here are
linked to `~/.config/zsh` and loaded by it. Plugins are managed by
[zap](https://github.com/zap-zsh/zap).

## Load order (`.zshrc`)

1. `brew shellenv`: Homebrew on `PATH`
2. zap
3. [mise](https://mise.jdx.dev): runtime versions (node, etc.). Replaced asdf and nvm
4. `~/env.zsh`: secrets and API keys, if present. Never committed
5. `alias.zsh`, `export.zsh`, `starship.zsh` (this directory)
6. zap plugins

## Files

| File           | What                                                              |
| -------------- | ----------------------------------------------------------------- |
| `alias.zsh`    | Aliases                                                           |
| `export.zsh`   | `EDITOR`, `BROWSER`, XDG, `PATH` incl. `~/.dotfiles/bin` (deduped with `typeset -gU path`: global, since zap sources it in a function) |
| `starship.zsh` | [starship](https://starship.rs) prompt; config in `config/starship` |

Machine- or work-specific settings go in `~/env.zsh`, not here.

## Plugins

| Plugin                                                                         | What                                                                  |
| ------------------------------------------------------------------------------ | --------------------------------------------------------------------- |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)         | Suggests commands from history as you type (→ to accept)              |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Highlights commands as you type                                       |
| [zsh-completions](https://github.com/zsh-users/zsh-completions)                 | Extra completion definitions                                          |
| [zap-zsh/supercharge](https://github.com/zap-zsh/supercharge)                   | Sensible defaults: completion setup (`compinit`), history (50k, deduped), `AUTO_CD`, keybindings |
| [zap-zsh/exa](https://github.com/zap-zsh/exa)                                   | `ls` / `ll` via [eza](https://github.com/eza-community/eza) (despite the name) |

supercharge already runs `compinit` and sets `HISTFILE`, so `.zshrc` doesn't.

## Aliases

| Alias                      | What                                 |
| -------------------------- | ------------------------------------ |
| `dotfiles`                 | `cd ~/.dotfiles` and open nvim       |
| `notes`                    | `cd ~/notes` and open nvim           |
| `assist`                   | Claude assistant session in `~/notes/assistant` (see [claude](../../claude/README.md#assistant)) |
| `change` / `update`        | Edit / re-source `~/.zshrc`          |
| `lg`                       | lazygit                              |
| `dcup` / `dcdown`          | `docker compose up -d` / `down`      |
| `wm-start` / `wm-restart`  | Start / restart yabai                |
| `shots` / `shots-prune`    | Open `~/screenshots` / delete files older than 30 days (keeps `macos/`) |
