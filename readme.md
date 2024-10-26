# dotfiles

configration of @ShortArrow

## Quick Test on Docker

```bash
git clone https://github.com/ShortArrow/dotfiles.git
cd dotfiles
docker compose up -d --build
docker compose exec nvim /bin/bash -c nvim
```

## check startuptime

```bash
nvim --startuptime ./startup.log
```

## No Them No Life

- CUI
  - Github CLI
  - PowerShell
- TUI
  - LazyDocker
  - LazyGit
  - Bottom
  - Zellij
  - Neovim
- WM
  - GlazeWM
  - Hyprland
  - i3wm
- GUI
  - Inkscape
  - Gimp
- ChromeExtensions
  - Vimium
  - DarkReader
  - uBlock Origin
  - uBlacklist
  - Google Translate
  - DeepL
  - Wikiwand
  - Google検索キーボードショートカット

## Add Docs

```bash
cd ./content/ja
ln -s ../../bash ./bash
```

or

```bash
hugo new ./content/ja/newmd.md
```

## Important Infomation Source

[Docs of nvim lsp](https://nvim-lsp.github.io/)
[color](https://www.pandanoir.info/entry/2019/11/02/202146)

## Road Map

- Add [mason.nvim](https://github.com/williamboman/mason-lspconfig.nvim)
