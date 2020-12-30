<p align="center">
  <img alt="header image" src="https://raw.githubusercontent.com/caarlos0/dotfiles.fish/master/docs/header.svg" height="350" />
  <h2 align="center">carlos' dotfiles</h2>
  <p align="center">Config files for Fish, Java, Ruby, Go, Editors, Terminals and more.</p>
</p>

---

Based on these [dotfiles](https://github.com/caarlos0/dotfiles.fish) by Carlos Becker. I modified his a bit
to fit my preferences, and will continue to add to mine and pull from his.

## Installation

### Dependencies

First, make sure you have all those things installed:

- `git`: to clone the repo
- `curl`: to download some stuff
- `tar`: to extract downloaded stuff
- `fish`: the shell
- `sudo`: some configs may need that

### Install

Then, run these steps:

```console
$ git clone https://gitlab.com/spencerjsimpson/dotfiles.git ~/.dotfiles
$ cd ~/.dotfiles
# I will be adding a step here that should download and install brew and vs-code for you
$ ./script/bootstrap.fish
```

> All changed files will be backed up with a `.backup` suffix.

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

## Recommended Software

For macOS, I recommend:

- iTerm: a better terminal emulator;

For both Linux and macOS:

- [`bat`](https://github.com/sharkdp/bat) a `cat` with wings;
- [`delta`](https://github.com/dandavison/delta) for better git diffs;
- [`dog`](https://dns.lookup.dog) the command-line DNS client;
- [`exa`](https://the.exa.website) a modern replacement for `ls`;
- [`fd`](https://github.com/sharkdp/fd) a simple, fast and user-friendly alternative to `find`;
- [`fzf`](https://github.com/junegunn/fzf) for a fuzzy-finder, used in `,t` on vim, for example;
- [`gh`](https://github.com/cli/cli) for more GitHub integration with the terminal;
- [`grc`](https://github.com/garabik/grc) to colorize command's outputs;
- [`kubectx`](https://github.com/ahmetb/kubectx) for better Kubernetes context and namespace switch;
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) a faster `grep`;

To install them all with `brew`:

```console
$ brew install bat git-delta dog exa fd fzf gh grc kubectx ripgrep
```

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
