# sjsimpson dotfiles

Config files for my coding environment in [neovim](https://neovim.io) and [tmux](https://github.com/tmux/tmux/wiki).
Eventually will contain my configuration for Arch Linux using AwesomeWM (maybe).

These dotfiles are based on [dotfiles](https://github.com/folke/dot) created by [folke](https://github.com/folke).

Obviously, these have been modified and simplified, but I will be adding to them over time.
An older iteration of these doftiles (including a separate readme) can be found [`old` branch](https://github.com/sjsimpson/dotfiles/tree/old) of this project.

## Installation

### Dependencies

Install [`brew`](https://brew.sh/) (if you're on a Mac):

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Now, brew can install basically everything else that you need.

- Anything listed as a dependency can be installed using brew unless otherwise stated
- I'll provide a list of commands to run later

Install `zsh` using `zap`:

```shell
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
```

Things I use in `zsh`:

- [`zap`](https://github.com/zap-zsh/zap)
- [`starship`](https://starship.rs/)

Now, make sure you have all dependencies installed:

- `git`: to clone the repo

...and some extras:

- [`bat`](https://github.com/sharkdp/bat) better version of `cat` for viewing file contents
- [`exa`](https://the.exa.website) a modern replacement for `ls`
- [`fzf`](https://github.com/junegunn/fzf) for a fuzzy-finder, used in `,t` on vim, for example
- [`grc`](https://github.com/garabik/grc) for colorizing of output

```shell
brew install starship git bat exa fzf grc
```

#### Terminal

I use `kitty` as my termial, and `tmux` as a multiplexer:

```shell
brew install kitty tmux lazygit
```

- [`kitty`](https://sw.kovidgoyal.net/kitty/): GPU-based terminal emulator
- [`tmux`](https://github.com/tmux/tmux/wiki): terminal multiplexer
- [`lazygit`](https://github.com/jesseduffield/lazygit/): Git GUI for terminal

#### Coding Environment

Neovim is my prefered code editor these days:

- [`nvim`](https://neovim.io/): text/code editor

Dependencies for our `neovim` setup:

- [`fd`](https://github.com/sharkdp/fd) a simple, fast and user-friendly alternative to `find` (package name is `fd-find`;
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) find description there, mostly installing to help Telescope play nice and ignore `node_modules`

```shell
brew install nvim fd ripgrep
```

We also need to install our nerd fonts. As far as icons go, I typically use the [Font Awesome](https://fontawesome.com/) icons if I can:

```shell
brew install --cask font-hack-nerd-font font-inconsolata-nerd-font
```

> This will install the following 2 fonts:
>
> - Hack Nerd Font
> - Inconsolata Nerd Font Mono

#### MacOS Remastered (optional)

You can completely skip this step if you would like, but these are tools I have used to get more out of MacOS features:

- [`yabai`](https://github.com/koekeishiya/yabai): tiling window manager for MacOS (install from github)
- [`skhd`](https://github.com/koekeishiya/skhd): shortcut manager for MacOS (install from github)
- [`sketchybar`](https://github.com/felixkratz/sketchybar): custom toolbar for MacOS (install using `brew`)

### Install

First, clone this repo:

```shell
git clone https://github.com/sjsimpson/dotfiles.git
```

Then, make sure you are in the folder where you cloned dotfiles. I usually clone mine into `~/.dotfiles`:

```shell
cd ~/.dotfiles
```

Then, for `nvim`, we will:

```shell
# ~/.dotfiles
mv ~/.config/nvim ~/.config/nvim.bak   # if you already have a config
ln -s (pwd)/config/nvim ~/.config/
```

> **_NOTE:_** This flow applies to things like `kitty`, `starship`, and basically everything in the config folder.

Others will need to be installed in other places:

zshrc:

```shell
# ~/.dotfiles
mv ~/.zshrc ~/.zshrc.bak
ln -s (pwd)/.zshrc ~/.zshrc
```

tmux:

```shell
# ~/.dotfiles
mv ~/.tmux.conf ~/.tmux.conf.bak
ln -s (pwd)/tmux/.tmux.conf ~/
```

gitconfig:

```shell
# ~/.dotfiles
mv ~/.gitconfig ~/.gitconfig.bak
ln -s (pwd)/git/gitconfig ~/.gitconfig
```

That should do it! Now you'll need to install plugins as you open apps, but for the most part that should happen automatically.

To revert these changes, simply delete the files/folders (mostly symlinks) you created, and rename your `*.bak` files/folders.

### Other

Other things you might need:

- `pnpm`
- `asdf` (not using currently, but considering it)
- `npm`
