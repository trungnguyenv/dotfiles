#!/usr/bin/env bash
# Switch WezTerm to the next theme in the list. WezTerm reloads automatically.
set -euo pipefail

config="$(dirname "$0")/wezterm.lua"
themes=(
	"Tokyo Night"
	"Tokyo Night Storm"
	"Catppuccin Mocha"
	"rose-pine"
	"GruvboxDark"
	"nord"
	"Kanagawa (Gogh)"
	"Everforest Dark (Gogh)"
	"Dracula (Official)"
	"OneHalfDark"
)

current=$(sed -n 's/^config.color_scheme = "\(.*\)"$/\1/p' "$config")
next=${themes[0]}
for i in "${!themes[@]}"; do
	if [[ ${themes[i]} == "$current" ]]; then
		next=${themes[(i + 1) % ${#themes[@]}]}
	fi
done

sed -i '' "s/^config.color_scheme = .*/config.color_scheme = \"$next\"/" "$config"
echo "$next"
