# CONFIG

configration of @ShortArrow

## Quick Test on Docker

```
git clone https://github.com/ShortArrow/dotfiles.git
cd dotfiles
docker compose up -d --build
docker compose exec nvim /bin/bash -c nvim
```

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

## No Them No Life

- neovim
- vscode
  - gitgraph
  - GitHub
- ChromeExtensions
  - Vimium
  - DarkReader
  - uBlock Origin
  - uBlacklist
  - Google Translate
  - DeepL
  - LeechBlock
  - Wikiwand 
  - Language Reacter
  - Google検索キーボードショートカット
- Bash
  - nmap
  - naabu
- Powershell
- GitHub

## Add Docs

```
cd ./content/ja
ln -s ../../bash ./bash
```

or

```
hugo new ./content/ja/newmd.md
```

## Important Infomation Source

[Docs of nvim lsp](https://nvim-lsp.github.io/)
[color](https://www.pandanoir.info/entry/2019/11/02/202146)

## Road Map

- Add [mason.nvim](https://github.com/williamboman/mason-lspconfig.nvim)
