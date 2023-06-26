#!/bin/bash

# Get the username of the user who launched the script
if [ "$EUID" -eq 0 ]; then
	# Check if the script is run by the root user directly
	if [ "" = "$SUDO_USER" ]; then
		if [ "" = "$1" ]; then
			orig_user=$1
		else
			echo 'Please set username at first argument'
		fi
	else
		orig_user="$SUDO_USER"
	fi
else
	echo 'Please run as root or using sudo.'
	exit 1
fi

# Get the home directory of the original user
orig_home="/home/$orig_user"
echo "$orig_home"

# make symbolic link
rm -rf "$orig_home/.bash_myplug"
rm -rf "/usr/local/bin/.bash_myplug"

REPO="$orig_home/Documents/GitHub/dotfiles/bash/src"

PLUG="$orig_home/.bash_myplug"
ln -s "$REPO" "$PLUG"
file "$PLUG" # check link

PLUG="/usr/local/bin/.bash_myplug"
ln -s "$REPO" "$PLUG"
file "$PLUG" # check link

# display guides after run this script
BACKQUOTE="\`"
echo "###########################################"
echo "Write this at the end of ${BACKQUOTE}~/.bashrc${BACKQUOTE}"
echo "${BACKQUOTE}source ~/.bash_myplug/bash_myplug.sh${BACKQUOTE}"
echo "###########################################"
