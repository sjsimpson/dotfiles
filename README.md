<p align="center">
  <img alt="header image" src="https://raw.githubusercontent.com/caarlos0/dotfiles.fish/master/docs/header.svg" height="350" />
  <h2 align="center">Spencer's dotfiles (stolen from Carlos' dotfiles)</h2>
  <p align="center">Config files for Fish, Java, Terminals and more.</p>
</p>

---

Based on these [dotfiles](https://github.com/caarlos0/dotfiles.fish) by Carlos Becker. I modified his a bit
to fit my preferences, and will continue to add to mine and pull from his.

## Installation

### Dependencies

First, make sure you have all those things installed:

- [`brew`](https://brew.sh/): installing Homebrew for managing technologies
- `git`: to clone the repo
- `curl`: to download some stuff
- `tar`: to extract downloaded stuff
- `sudo`: some configs may need that
- `fish`: the shell
- [`bat`](https://github.com/sharkdp/bat) a `cat` with wings;
- [`exa`](https://the.exa.website) a modern replacement for `ls`;
- [`fd`](https://github.com/sharkdp/fd) a simple, fast and user-friendly alternative to `find`;
- [`fzf`](https://github.com/junegunn/fzf) for a fuzzy-finder, used in `,t` on vim, for example;
- [`grc`](https://github.com/garabik/grc) for colorizing of output. Install using `brew install grc`
- `delta`: better git diffs

To do this, first add `brew`:

```console
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Warning: `brew` might be installed in `/opt` with M1 chips. So you might have to add this to your `~/.config/fish/config.fish`:

```console
# Add bin and homebrew bin to path
set -U fish_user_paths /usr/local/bin /opt/homebrew/bin $fish_user_paths
```

Then, use `brew` to install these dependencies:

```console
$ brew install fish bat exa fd fzf grc delta
```

Next, install apps that we'll need:

- [VS Code](https://code.visualstudio.com/download): my preferred code editor
- [iTerm 2](https://iterm2.com/downloads.html): my preferred terminal


Once these are all installed, you can move on to installing the dotfiles.
### Install

Then, run these steps:

```console
$ git clone https://gitlab.com/spencerjsimpson/dotfiles.git ~/.dotfiles
$ cd ~/.dotfiles
# I will be adding a step here that should download and install brew and vs-code for you
$ ./script/bootstrap.fish
```

> All changed files will be backed up with a `.backup` suffix.


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


#### Update

To update, you just need to `git pull` and run the bootstrap script again:

```console
$ cd ~/.dotfiles
$ git pull origin master
$ ./script/bootstrap.fish
```

## Revert

Reverting is not totally automated, but it pretty much consists in removing
the fish config and dotfiles folder, as well as moving back some config files.

**Remove the folders:**

```console
$ rm -rf ~/.dotfiles ~/.config/fish
```

**Some config files were changed, you can find them using `fd`:**

```console
$ fd -e backup -e local -H -E Library -d 3 .
```

And then manually inspect/revert them.
## macOS defaults

You use it by running:

```console
~/.dotfiles/macos/set-defaults.sh
```

And logging out and in again or restart.

## Themes and fonts being used

Theme is **[Nord](https://nordtheme.com)** and font is **Inconsolata**.

## Screenshots

![screenshot 1][scrn1]

![screenshot 2][scrn2]

[scrn1]: /docs/screenshot1.png
[scrn2]: /docs/screenshot2.png
