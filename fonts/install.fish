#!/usr/bin/env fish
if command -qs brew
    brew tap -q homebrew/cask-fonts
        and brew install --cask font-mononoki-nerd-font
end
