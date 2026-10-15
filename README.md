# sjsimpson dotfiles

macOS dev environment: zsh, kitty, tmux, neovim, plus Claude Code config.
Originally based on [folke's dotfiles](https://github.com/folke/dot), since
simplified. Older iteration lives on the [`old` branch](https://github.com/sjsimpson/dotfiles/tree/old).

## Install

```shell
# 1. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. zap (zsh plugin manager)
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1

# 3. clone + install
git clone https://github.com/sjsimpson/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh --brew
```

`install.sh` is idempotent: it symlinks everything into place, moves any
existing file to `<name>.bak`, and clones [tpm](https://github.com/tmux-plugins/tpm).
`--brew` also runs `brew bundle` against the [`Brewfile`](Brewfile). To undo,
delete the symlinks and restore the `.bak` files.

Afterwards:

- Open tmux and press `prefix + I` to install tmux plugins
- Open nvim; [lazy.nvim](https://github.com/folke/lazy.nvim) and Mason install
  plugins, LSPs, and formatters on first launch

### Not in the repo

| File                 | Purpose                                                |
| -------------------- | ------------------------------------------------------ |
| `~/env.zsh`          | Secrets / API keys, sourced by `.zshrc` if present     |
| `~/.gitconfig.local` | Machine-specific git config (work email, tool IDs)     |

## Layout

| Path               | Linked to                            | What                                             |
| ------------------ | ------------------------------------ | ------------------------------------------------ |
| `.zshrc`           | `~/.zshrc`                           | zsh via [zap](https://github.com/zap-zsh/zap), [starship](https://starship.rs) prompt, [mise](https://mise.jdx.dev) for runtimes |
| `config/*`         | `~/.config/*`                        | nvim, kitty, ghostty, lazygit, starship, zsh, …  |
| `tmux/tmux.conf`   | `~/.tmux.conf`                       | tmux + tpm plugins, TokyoNight theme             |
| `git/gitconfig`    | `~/.gitconfig`                       | git, [delta](https://github.com/dandavison/delta) pager |
| `git/ignore`       | `~/.config/git/ignore`               | global gitignore                                 |
| `bin/`             | on `$PATH`                           | scripts (e.g. `gh-review`)                       |
| `claude/`          | `~/.claude/` (per file)              | Claude Code instructions, settings, agents, skills |

### Terminal

[kitty](https://sw.kovidgoyal.net/kitty/) is the main terminal
([ghostty](https://ghostty.org) config kept for trying it out), with
[tmux](https://github.com/tmux/tmux/wiki) and
[lazygit](https://github.com/jesseduffield/lazygit). Font is Iosevka Term
(Nerd Font), theme is TokyoNight Storm everywhere.

### Neovim

Config lives in `config/nvim`. Plugins managed by lazy.nvim, LSPs/linters/
formatters by Mason. Telescope needs `fd` and `ripgrep` (both in the Brewfile).

### `bin/`

- `gh-review <pr|branch>`: throwaway git worktree for reviewing a PR; `--claude`
  launches Claude Code in it. `gh-review --help` for more.

### Claude Code

`claude/` holds my own Claude Code config. `install.sh` links **individual
files and skill dirs** into `~/.claude/` rather than the whole directory,
because other tools install into `~/.claude/skills` too.

- `CLAUDE.md`: global instructions
- `settings.json`: hooks, permissions, plugins
- `agents/`: custom subagents
- `skills/`: custom skills (`/claude-panel`, `/review-pr`)

Third-party skills aren't vendored (see `~/.agents/.skill-lock.json`); reinstall with:

```shell
npx skills add JuliusBrussee/caveman   # caveman*, cavecrew, lean-build, surgical-patch, …
npx skills add vercel-labs/skills      # find-skills
```

## macOS window management (optional)

[yabai](https://github.com/koekeishiya/yabai),
[skhd](https://github.com/koekeishiya/skhd), and
[sketchybar](https://github.com/felixkratz/sketchybar) configs are in
`config/`. Not installed by default (commented out in the Brewfile); see each
project's install docs. `wm-start` / `wm-restart` aliases control yabai.
