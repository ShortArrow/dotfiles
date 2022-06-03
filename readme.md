# CONFIG

configration of @ShortArrow

## overview

1. install neovim
1. git clone this repository
1. make symboliclink of neovim dotfile
1. install packer
1. run packerinstall command
1. install nerd font
1. install git-foresta
1. install tmux
1. make symboliclink of tmux dotfile

## Usage

### Windows

Make Junction.

```powershell
# If you need backup, run `cp $env:USERPROFILE/.config/nvim $env:USERPROFILE/.config/nvim.backup`
rm ./nvim/ -recuse -force
New-Item -Type Junction -Name ./nvim/ -Value $env:USERPROFILE\AppData\Local\nvim\
```

### Linux

Make SymbolicLink

```bash
mkdir $HOME/Documents/GitHub/
git clone https://github.com/ShortArrow/my-nvim-config.git $HOME/Documents/GitHub/my-nvim-config
cd $HOME/Documents/GitHub/my-nvim-config
# If you need backup, run `cp ~/.config/nvim ~/.config/nvim.backup`
rm -rf ~/.config/nvim
ln -s $HOME/Documents/GitHub/my-nvim-config/nvim ~/.config/nvim # caution! Don't needs slash at last.
ls ~/.config/nvim # check link
```

## Install Packer

https://github.com/wbthomason/packer.nvim/blob/master/README.md#quickstart

run ExCommand`:PackerInstall` on nvim command mode.

## Install Nerd fonts

Install from [nerdfonts.com](https://www.nerdfonts.com/).

```bash
sudo mkdir /usr/share/fonts/nerd/
sudo curl -fLo "/usr/share/fonts/nerd/Blex Mono Nerd Font Complete.otf" \
    https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/IBMPlexMono/Mono/complete/Blex%20Mono%20Nerd%20Font%20Complete.ttf
fc-cache
fc-list | grep nerd # check
```

> **Note**
> If you using WSL, check config of Windows Terminal.

## Install Neovim

### Debian

```bash
wget -O /tmp/nvim.deb https://github.com/neovim/neovim/releases/download/v0.7.0/nvim-linux64.deb
sudo apt install /tmp/nvim.deb
```

## git-foresta

Install

```bash
sudo curl -L https://github.com/takaaki-kasai/git-foresta/raw/master/git-foresta \
  -o /bin/git-foresta && sudo chmod +x /bin/git-foresta
```

Usage

```bash
git-foresta --all --style=15  | less -RSX
```

## Tmux Config

# Installation pattern 3

1. Create `.tmux` folder in your home directory: `mkdir ~/.tmux`

2. To download, run the following command:

```bash
wget -O $HOME/.tmux/iceberg_minimal_with_win_index.tmux.conf \
https://raw.githubusercontent.com/ShortArrow/iceberg-dark/master/.tmux/iceberg_minimal_with_win_index.tmux.conf
```

3. Add `source-file ~/.tmux/iceberg_minimal_with_win_index.tmux.conf` to your `~/.tmux.conf`

