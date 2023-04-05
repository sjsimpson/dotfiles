<p align="center">
  <img alt="header image" src="https://raw.githubusercontent.com/caarlos0/dotfiles.fish/master/docs/header.svg" height="350" />
  <h2 align="center">sjsimpson dotfiles</h2>
  <p align="center">Config files for my coding environment in [neovim](https://neovim.io) and [tmux](https://github.com/tmux/tmux/wiki).</p>
  <p align="center">Eventually will contain my configuration for Arch Linux using AwesomeWM.
</p>

---

These dotfiles are based on [dotfiles](https://github.com/folke/dot) created by The Great [folke](https://github.com/folke).

Obviously, these have been modified and simplified, but I will be adding to them over time.
An older iteration of these doftiles can be found [`old` branch](https://github.com/sjsimpson/dotfiles/tree/old) of this project.


## Installation

### Dependencies

First, make sure you have all dependencies installed:

- `git`: to clone the repo
- `curl`: to download some stuff
- `tar`: to extract downloaded stuff
- `sudo`: some configs may need that
- [`fish`](https://fishshell.com/): the shell
- [`nvim`](https://neovim.io/): our preffered text/code editor
- [`kitty`](https://sw.kovidgoyal.net/kitty/): GPU-based terminal emulator
- [`tmux`](https://github.com/tmux/tmux/wiki): terminal multiplexer

Dependencies for our `neovim` setup:

- [`fd`](https://github.com/sharkdp/fd) a simple, fast and user-friendly alternative to `find` (package name is `fd-find`;
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) find description there, mostly installing to help Telescope play nice and ignore `node_modules`


These are some helpful tools, but don't affect installation:

- [`bat`](https://github.com/sharkdp/bat) a `cat` with wings;
- [`exa`](https://the.exa.website) a modern replacement for `ls`;
- [`fzf`](https://github.com/junegunn/fzf) for a fuzzy-finder, used in `,t` on vim, for example;
- [`grc`](https://github.com/garabik/grc) for colorizing of output. Install using `brew install grc`

I would include installation documentation for each of these, but that's quite a lot. So, instead, I've provided links that you can follow.


### Install

So far, installation consists of copying files to their correct directories. Most of them should live in the `~/.config/`, so other than this example, I'll only give instructions on exceptions.

For `nvim`, we will:
```shell
# ~/.dotfiles
$ mv ~/.config/nvim ~/.config/nvim.bak   # if you already have a config
$ ln -s (pwd)/config/nvim ~/.config/
```

This flow applies to things like `kitty`, `starship`... and probably others, but give me a break, I'm just getting this started.

Others will need to be installed in other places:

tmux:
```shell
# ~/.dotfiles
$ mv ~/.tmux.conf ~/.tmux.conf.bak
$ ln -s (pwd)/tmux/.tmux.conf ~/
```

EditorConfig is still here for now. But I might change it shortly:
```shell
# ~/.dotfiles
$ mv ~/.editorconfig ~/.editorconfig.bak
$ ln -s editorconfig/editorconfig.symlink ~/.editorconfig
```

That should do it! Now you'll need to install plugins as you open apps, but for the most part that should happen automatically.

To revert these changes, simply delete the files/folders you created, and rename your `*.bak` files/folders.

## Old Instructions (but still useful-ish)
### Pyenv

First, install `pyenv` using `brew`:

```console
$ brew install pyenv
```

Then, add this to your `~/.config/fish/config.fish`:

```console
setenv PYENV_ROOT "$HOME/.pyenv"
setenv PATH "$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
pyenv rehash
```

You can now install python versions that you need and use them!!


### NVM

Follow the instructions [`here`](https://eshlox.net/2019/01/27/how-to-use-nvm-with-fish-shell/):

Install `nvm` using `brew`:
```console
$ brew install nvm
```

Add fish function to `~/.config/fish/functions/nvm.fish` (I will automate this eventually):
```console
function nvm
    bass source (brew --prefix nvm)/nvm.sh --no-use ';' nvm $argv
end
```

`bass` should already be installed as a `fisher` package, and listed in `~/.config/fish/fisher_plugins` as `edc/bass`.

### Mac

If you're configuring this on Mac, I would recommend using `brew` to install the majority of these dependencies. But first, you'll need to install `brew`:

```console
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Warning: `brew` might be installed in `/opt` with M1 chips. So you might have to add this to your `~/.config/fish/config.fish`:

```console
# Add bin and homebrew bin to path
set -U fish_user_paths /usr/local/bin /opt/homebrew/bin $fish_user_paths
```

Because I have yet to configure most of this on Mac, I'm not sure how friendly `kitty` is (feel free to read their documentation). I previously used `iterm2`, which should work fine, you'll just need to add your own configuration/theme:

- [iTerm 2](https://iterm2.com/downloads.html): my preferred terminal

