---
title: "Bash"
description: "bash config is here"
summary: "bash config"
tags: ["docs"]
---

## Usage

1. Make symboliclink.

```bash
# remove previous files
rm -rf ~/.bash_myplug
rm -rf /usr/lobal/bin/.bash_myplug
# make symbolic links
ln -s $HOME/Documents/GitHub/dotfiles/bash/bash_myplug.sh ~/.bash_myplug
ln -s $HOME/Documents/GitHub/dotfiles/bash/bash_myplug.sh /usr/local/bin/.bash_myplug
# check
file ~/.bash_myplug
file /usr/local/bin/.bash_myplug
```

1. Write this at the end of `~/.bashrc`.

```bash
source ~/.bash_myplug/bash_myplug.sh
```

1. For load the settings. Reopen bash, or run command as bellow in current bash terminal.

```bash
source ~/.bashrc
```

## Auto setup

Run this command.

```
sudo -E bash ./setup.sh
```

## Dependencies

- [starship](https://starship.rs)
- [dotnet](https://docs.microsoft.com/ja-jp/dotnet/core/install/)

## LSP

```bash
:MasonInstall bash-language-server
:MasonInstall shellcheck
:MasonInstall shellfmt
```
