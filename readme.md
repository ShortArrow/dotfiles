# NVIM CONFIG

neovim configration of @ShortArrow

## overview

1. make junction
2. clone packer
3. run packerinstall command

## Make Junction

```powershell
rm ./nvim/ -recuse -force
New-Item -Type Junction -Name ./nvim/ -Value C:\Users\who\AppData\Local\nvim\
```

## Install Packer

https://github.com/wbthomason/packer.nvim/blob/master/README.md#quickstart

run ExCommand`:PackerInstall` on nvim command mode.

