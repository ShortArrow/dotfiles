---
title : 'Neovim'
summary: "neovim config"
tags: ["docs"]
---

# my nvim settings

## Usage

Make SymbolicLink.

### Windows

```powershell
Remove-Item ./nvim/ -Recurse -Force
New-Item -Type SymbolicLink -Path "$env:LOCALAPPDATA" -Name "nvim" -Value "$env:USERPROFILE/Documents/GitHub/dotfiles/nvim"
Get-ChildItem -Path $env:LOCALAPPDATA -Force -ErrorAction 'silentlycontinue' |
Where-Object { $_.Attributes -match "ReparsePoint" -and $_.Name -match "nvim"}
```

### Linux

```bash
rm -rf ~/.config/nvim
ln -s $HOME/Documents/GitHub/dotfiles/nvim ~/.config/nvim # caution! Don't needs slash at last.
ls ~/.config/nvim # check link
```

## Install Packer

<https://github.com/wbthomason/packer.nvim/blob/master/README.md#quickstart>

### win

```bash
git clone https://github.com/wbthomason/packer.nvim "$env:LOCALAPPDATA\nvim-data\site\pack\packer\start\packer.nvim"
```

### Linux

```bash
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

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

## Neovim colorscheme

```bash
mkdir ~/.config/nvim/colors/
curl https://raw.githubusercontent.com/cocopon/iceberg.vim/master/src/iceberg.vim -o ~/.config/nvim/colors/iceberg.vim
```



