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

`install.sh` is idempotent. It:

- asks for missing personal values (e.g. the ntfy topic for assistant pings;
  blank generates one) and writes them to `~/env.zsh`
- symlinks everything into place (moving any existing file to `<name>.bak`)
- installs the Claude Code plugins listed in `claude/settings.json`
- links the herdr plugins in `config/herdr/plugins/`
- installs Playwright's ffmpeg (video recording in the Playwright MCP)
- loads the `launchd/` jobs (assistant brief/wind-down only if
  `~/notes/assistant` exists)
- points macOS screenshots at `~/screenshots/macos`

Flags:

- `--brew`: run `brew bundle` against the [`Brewfile`](Brewfile)

To undo, delete the symlinks and restore the `.bak` files. On first launch,
nvim installs its plugins, LSPs, and formatters automatically.

### Not in the repo

| File                 | Purpose                                                |
| -------------------- | ------------------------------------------------------ |
| `~/env.zsh`          | Secrets / personal values, sourced by `.zshrc`; `install.sh` prompts for missing ones |
| `~/.gitconfig.local` | Machine-specific git config (work email, tool IDs)     |

## Layout

| Path               | Linked to                            | What                                             |
| ------------------ | ------------------------------------ | ------------------------------------------------ |
| `.zshrc`           | `~/.zshrc`                           | zsh; details in [`config/zsh`](config/zsh/README.md) |
| `config/*`         | `~/.config/*`                        | nvim ([README](config/nvim/README.md)), kitty, ghostty, herdr, lazygit, starship, zsh ([README](config/zsh/README.md)) |
| `git/gitconfig`    | `~/.gitconfig`                       | git, [delta](https://github.com/dandavison/delta) pager |
| `git/ignore`       | `~/.config/git/ignore`               | global gitignore                                 |
| `bin/`             | on `$PATH`                           | scripts (e.g. `gh-review`)                       |
| `claude/`          | `~/.claude/` (per file)              | Claude Code ([README](claude/README.md))          |
| `launchd/`         | copied to `~/Library/LaunchAgents`   | scheduled jobs (`assistant-brief`: 08:30 brief, 16:45 wind-down) |

## Tools

Everything below is in the [`Brewfile`](Brewfile). Font is Iosevka Term (Nerd
Font); theme is TokyoNight Storm everywhere.

**Terminal + agents**

- [kitty](https://sw.kovidgoyal.net/kitty/): GPU-based terminal, main terminal
- [ghostty](https://ghostty.org): config kept while I try it out
- [herdr](https://herdr.dev): agent multiplexer for running Claude Code
  sessions side by side. Replaces tmux; only `config.toml` is tracked
  because herdr keeps runtime state in the same directory. Plugins in
  `config/herdr/plugins/` are linked by `install.sh`; `wt-env` runs a repo's
  `scripts/wt-setup` / `wt-teardown` (or private ones in
  `~/.config/wt-env/<repo>/`) on worktree create/remove,
  and `prefix+d` opens its runtimes dashboard: per workspace, agents and their
  state, pane processes with CPU/mem and listening ports, and the docker
  compose containers started from that checkout

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
- `assistant-brief [brief|winddown|prep] [--force|--dry]`: headless
  `/triage` into the assistant home, then an [ntfy](https://ntfy.sh)
  phone push (`ASSISTANT_NTFY_TOPIC` in `~/env.zsh`, prompted by `install.sh`)
  and a Mac notification, counts only. launchd runs the brief at 08:30 daily and the
  wind-down at 16:45 weekdays (Thu adds 1:1 prep); see
  [Assistant](claude/README.md#assistant).

- `http-status <url>`: HTTP status of a localhost URL only (no redirects, no
  body); allowlisted for agents' health checks (`Bash(http-status:*)`);
  `install.sh` also links it into `~/.local/bin`
- `qa-login <url>`: log in by hand to `qa-tester`'s golden Chrome profile;
  every worktree's copy re-seeds from it
- `pr-threads <pr> [--json]`: every piece of feedback on a PR (threads with
  open/resolved/outdated, reviews, comments, my pending review); the review
  skills read it. `install.sh` links it into `~/.local/bin`
- `pr-pending list|sync <pr>`: findings into my pending review, never
  submits; sets/updates the review body (what was tested); only touches
  comments and a body it posted that I haven't edited (`--replace-body`
  overrides, on my OK)
- `basecamp-safe`: the `basecamp` CLI limited to reads + message drafts
  (`--draft` forced); the assistant may run only this
- `qa-browser`: `qa-tester`'s Playwright MCP launcher (per-worktree profile
  copy, headless); `install.sh` links it into `~/.local/bin`

## Claude Code

`claude/` holds my Claude Code setup: global `CLAUDE.md`, settings and hooks,
agents, and skills. See [`claude/README.md`](claude/README.md).

## macOS window management (optional)

[yabai](https://github.com/koekeishiya/yabai),
[skhd](https://github.com/koekeishiya/skhd), and
[sketchybar](https://github.com/felixkratz/sketchybar) configs are in
`config/`. Not installed by default (commented out in the Brewfile); see each
project's install docs. `wm-start` / `wm-restart` aliases control yabai.

