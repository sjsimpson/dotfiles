# sjsimpson dotfiles

Config files for my coding environment in [neovim](https://neovim.io) and [tmux](https://github.com/tmux/tmux/wiki).
Eventually will contain my configuration for Arch Linux using AwesomeWM (maybe).

These dotfiles are based on [dotfiles](https://github.com/folke/dot) created by [folke](https://github.com/folke).

Obviously, these have been modified and simplified, but I will be adding to them over time.
An older iteration of these doftiles (including a separate readme) can be found [`old` branch](https://github.com/sjsimpson/dotfiles/tree/old) of this project.

## Installation

### Dependencies

Install `brew` (if you're on a Mac):

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Now, brew can install basically everything else that you need.

- Anything listed as a dependency can be installed using brew unless otherwise stated
- I'll provide a list of commands to run later

Install `zsh`:

```shell
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
```

Things I use in `zsh`:

- [`zap`](https://github.com/zap-zsh/zap)
- [`starship`](https://starship.rs/)

Now, make sure you have all dependencies installed:

- `git`: to clone the repo
- `curl`: to download some stuff
- `tar`: to extract downloaded stuff
- `sudo`: some configs may need that

...and some extras:

- [`bat`](https://github.com/sharkdp/bat) better version of `cat` for viewing file contents
- [`exa`](https://the.exa.website) a modern replacement for `ls`
- [`fzf`](https://github.com/junegunn/fzf) for a fuzzy-finder, used in `,t` on vim, for example
- [`grc`](https://github.com/garabik/grc) for colorizing of output

#### Terminal

I use `kitty` as my termial, and `tmux` as a multiplexer:

- [`kitty`](https://sw.kovidgoyal.net/kitty/): GPU-based terminal emulator
- [`tmux`](https://github.com/tmux/tmux/wiki): terminal multiplexer
- [`lazygit`](https://github.com/jesseduffield/lazygit/): Git GUI for terminal

#### Coding Environment

Neovim is my prefered code editor these days:

- [`nvim`](https://neovim.io/): text/code editor

Dependencies for our `neovim` setup:

- [`fd`](https://github.com/sharkdp/fd) a simple, fast and user-friendly alternative to `find` (package name is `fd-find`;
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) find description there, mostly installing to help Telescope play nice and ignore `node_modules`

We also need to install our nerd fonts. As far as icons go, I typically use the [Font Awesome](https://fontawesome.com/) icons if I can:

- Hack Nerd Font
- Inconsolata Nerd Font Mono

#### MacOS Remastered (optional)

You can completely skip this step if you would like, but these are tools I have used to get more out of MacOS features:

- [`yabai`](): tiling window manager for MacOS
- [`skhd`](): shortcut manager for MacOS
- [`sketchybar`](): custom toolbar for MacOS

### Install

So far, installation consists of copying files to their correct directories. Most of them should live in the `~/.config/`, so other than this example, I'll only give instructions on exceptions.

First, we will need to back up our extisting configs:

```shell
mv ~/.config/fish ~/.config/fish.bak
mv ~/.config/kitty ~/.config/kitty.bak
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.config/starship ~/.config/starship.bak
mv ~/.editorconfig ~/.editorconfig.bak
mv ~/.tmux.conf ~/.tmux.conf.bak
```

Then, we can link files from our `~/.dotfiles/` folder:

```shell
# Move to the directory where we stored our dotfiles
cd `~/.dotfiles`  # or whatever you decide your path is

# Create symlinks for all of our configs
ln -s (pwd)/config/fish ~/.config/
ln -s (pwd)/config/kitty ~/.config/
ln -s (pwd)/config/nvim ~/.config/
ln -s (pwd)/config/starship ~/.config/
ln -s (pwd)/config/tmux/.tmux.conf ~/.tmux.conf
ln -s (pwd)/editorconfig/editorconfig.symlink ~/.editorconfig
```

For `nvim`, we will:

```shell
# ~/.dotfiles
mv ~/.config/nvim ~/.config/nvim.bak   # if you already have a config
ln -s (pwd)/config/nvim ~/.config/
```

This flow applies to things like `kitty`, `starship`... and probably others, but give me a break, I'm just getting this started.

Others will need to be installed in other places:

tmux:

```shell
# ~/.dotfiles
mv ~/.tmux.conf ~/.tmux.conf.bak
ln -s (pwd)/config/tmux/.tmux.conf ~/
```

EditorConfig is still here for now. But I might change it shortly:

```shell
# ~/.dotfiles
mv ~/.editorconfig ~/.editorconfig.bak
ln -s (pwd)/editorconfig/editorconfig.symlink ~/.editorconfig
```

That should do it! Now you'll need to install plugins as you open apps, but for the most part that should happen automatically.

To revert these changes, simply delete the files/folders you created, and rename your `*.bak` files/folders.

Other things you might need:

- `pnpm`
- `asdf`
- `npm`
