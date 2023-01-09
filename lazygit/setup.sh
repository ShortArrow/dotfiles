#!/bin/bash

# Function to check if a directory exists
directory_exists() {
	if [ -d "$1" ]; then
		return 0 # Directory exists
	else
		return 1 # Directory does not exist
	fi
}

# Function to check if a command exists
command_exists() {
	if which "$1" >/dev/null; then
		return 0 # The command was found, return success
	else
		return 1 # The command was not found, return failure
	fi
}

if command_exists "lazygit"; then
	echo "lazygit command found"
	ln -s -f "$HOME/Documents/GitHub/dotfiles/lazygit/config.yaml" "$HOME/.config/lazygit/config.yml"
  file "$HOME/.config/lazygit/config.yml"
else
	if directory_exists "$HOME/Documents/GitHub/lazygit/"; then
		echo "GitHub directory found"
		ln -s "$HOME/Documents/GitHub/lazygit/" "$HOME/.local/bin/lazygit"
    file "$HOME/.local/bin/lazygit"
	else
		printf "clone repository not found\nPlease clone \`git clone https://github.com/lazygit\`"
	fi
fi

