# sjsimpson dotfiles

macOS dev environment: zsh, kitty, herdr, neovim, plus Claude Code config.
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
existing file to `<name>.bak`. Flags:

- `--brew`: run `brew bundle` against the [`Brewfile`](Brewfile)
- `--skills`: install third-party Claude skills listed in [`claude/skills.txt`](claude/skills.txt)

To undo, delete the symlinks and restore the `.bak` files. On first launch,
nvim installs its plugins, LSPs, and formatters automatically.

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
| `git/gitconfig`    | `~/.gitconfig`                       | git, [delta](https://github.com/dandavison/delta) pager |
| `git/ignore`       | `~/.config/git/ignore`               | global gitignore                                 |
| `bin/`             | on `$PATH`                           | scripts (e.g. `gh-review`)                       |
| `claude/`          | `~/.claude/` (per file)              | Claude Code instructions, settings, agents, skills |

## Tools

Everything below is in the [`Brewfile`](Brewfile). Font is Iosevka Term (Nerd
Font); theme is TokyoNight Storm everywhere.

**Terminal + agents**

- [kitty](https://sw.kovidgoyal.net/kitty/): GPU-based terminal, main terminal
- [ghostty](https://ghostty.org): config kept while I try it out
- [herdr](https://herdr.dev): agent multiplexer for running Claude Code
  sessions side by side. Replaces tmux; only `config.toml` is tracked
  because herdr keeps runtime state in the same directory

**Shell**

- [zap](https://github.com/zap-zsh/zap): zsh plugin manager
- [starship](https://starship.rs): prompt
- [mise](https://mise.jdx.dev): runtime/version manager (replaced asdf, nvm)
- [eza](https://github.com/eza-community/eza): `ls` replacement
- [bat](https://github.com/sharkdp/bat): `cat` with syntax highlighting
- [fzf](https://github.com/junegunn/fzf): fuzzy finder
- [grc](https://github.com/garabik/grc): colorizes command output
- [jq](https://jqlang.org): JSON on the command line
- [httpie](https://httpie.io): friendlier `curl` for APIs
- [taskwarrior](https://taskwarrior.org) (`task`): CLI todo list

**Git**

- [gh](https://cli.github.com): GitHub CLI (PRs, reviews, `gh stack`)
- [delta](https://github.com/dandavison/delta): diff pager
- [lazygit](https://github.com/jesseduffield/lazygit): git TUI (`lg`)

**Editor**

- [neovim](https://neovim.io): config in `config/nvim`. Plugins via
  [lazy.nvim](https://github.com/folke/lazy.nvim); LSPs, linters, and
  formatters via Mason
- [fd](https://github.com/sharkdp/fd) + [ripgrep](https://github.com/BurntSushi/ripgrep):
  fast search for Telescope

**Provisional** (trying out, may drop)

- [mosh](https://mosh.org) + [moshi](https://github.com/rjyo/moshi): remote
  sessions and Claude Code hooks for them

### tmux (retired)

I used tmux before herdr. The config lives on the
[`tmux` branch](https://github.com/sjsimpson/dotfiles/tree/tmux).

## `bin/`

- `gh-review <pr|branch>`: throwaway git worktree for reviewing a PR; `--claude`
  launches Claude Code in it. `gh-review --help` for more.

## Claude Code

`claude/` holds my own Claude Code config. `install.sh` links **individual
files and skill dirs** into `~/.claude/` rather than the whole directory,
because other tools install into `~/.claude/skills` too.

- `CLAUDE.md`: global instructions
- `settings.json`: hooks, permissions, plugins
- `agents/`: custom subagents
- `skills/`: custom skills (`/claude-panel`)

Third-party skills aren't vendored. They're listed in `claude/skills.txt`
and installed with `install.sh --skills` (via [`npx skills`](https://github.com/vercel-labs/skills)).
When you add one with `npx skills add`, add it to `skills.txt` too.

## macOS window management (optional)

[yabai](https://github.com/koekeishiya/yabai),
[skhd](https://github.com/koekeishiya/skhd), and
[sketchybar](https://github.com/felixkratz/sketchybar) configs are in
`config/`. Not installed by default (commented out in the Brewfile); see each
project's install docs. `wm-start` / `wm-restart` aliases control yabai.

## TODO

- [ ] Agents: decide whether any custom subagents earn their keep; consider
  repo-specific `*-reviewer` agents that `claude-panel` picks up
- [ ] Skills: compare `claude-panel` vs built-in `/code-review` on a real PR;
  drop the panel if it doesn't find meaningfully more
- [ ] Skills: write `audit` (whole-repo review, plus a dotfiles drift mode)
- [ ] Skills: `address-pr-comments`, `start-ticket ENG-xxxx`
- [ ] Skills: package my own skills as a Claude Code plugin so they install
  like third-party ones
