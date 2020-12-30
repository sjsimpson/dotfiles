#!/usr/bin/env fish
if command -qa exa
	abbr -a ls 'exa -aFG'
	abbr -a lg 'exa --git'
	abbr -a l 'exa -lah'
	abbr -a ll 'exa -l'
	abbr -a lt 'exa -lT'
else
	abbr -a l 'ls -lAh'
	abbr -a la 'ls -A'
	abbr -a ll 'ls -l'
end
