#!/usr/bin/env fish
#
if ! command -qs code
	exit 0
end

switch (uname)
case Darwin
	set vscode_home "$HOME/Library/Application Support/Code"
case '*'
	set vscode_home "$HOME/.config/Code"
end

mkdir -p $vscode_home
	and ln -sf "$DOTFILES/vscode/settings.json" "$vscode_home/User/settings.json"
	and ln -sf "$DOTFILES/vscode/keybindings.json" "$vscode_home/User/keybindings.json"
	and echo "vscode: linked config files"

cat $DOTFILES/vscode/extensions.txt | while read module
	code --install-extension "$module"
		and echo "vscode: $module"
		or echo "vscode: failed to install $module"
end
