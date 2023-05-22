#!/bin/bash

source "$HOME/.bash_myplug/bash_checkers.sh"

# vivid
if is-arch; then
	pacman --noconfirm -Syuu
	pacman --noconfirm -S vivid
else

	cargo install vivid
fi

