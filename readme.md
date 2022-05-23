# NVIM CONFIG

neovim configration of @ShortArrow

## overview

1. make junction
2. clone packer
3. run packerinstall command

## Usage

### Windows

Make Junction.

```powershell
# If you need backup, run `cp ~/.config/nvim ~/.config/nvim.backup`
rm ./nvim/ -recuse -force
New-Item -Type Junction -Name ./nvim/ -Value C:\Users\who\AppData\Local\nvim\
```

### Linux

Make 

```bash
# If you need backup, run `cp ~/.config/nvim ~/.config/nvim.backup`
rm -rf ~/.config/nvim
ln -s /home/who/Documents/GitHub/my-nvim-config/nvim ~/.config/nvim # caution! Don't needs slash at last.
```

## Install Packer

https://github.com/wbthomason/packer.nvim/blob/master/README.md#quickstart

run ExCommand`:PackerInstall` on nvim command mode.

## Install Nerd fonts

Install from [here](https://www.nerdfonts.com/).

