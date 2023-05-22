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
	if which "$1" >/dev/null 2>&1; then
		return 0 # The command was found, return success
	else
		return 1 # The command was not found, return failure
	fi
}

# Function to check here is on arch
is-arch() {
	if [[ $(uname -r) =~ "arch" ]]; then
		return 0 # This is Archlinux.
	else
		return 1 # This is not Archlinux.
	fi
}
