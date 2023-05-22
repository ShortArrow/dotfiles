#!/bin/bash

source "$HOME/.bash_myplug/bash_checkers.sh"

# vivid
if command_exists "vivid"; then
	export LS_COLORS="$(vivid generate molokai)"
else
	echo "please install vivid"
fi

