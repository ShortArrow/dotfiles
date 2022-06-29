# my nvim settings

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

## Neovim colorscheme

```bash
mkdir ~/.config/nvim/colors/
curl https://raw.githubusercontent.com/cocopon/iceberg.vim/master/src/iceberg.vim -o ~/.config/nvim/colors/iceberg.vim
```



