---
title: "Python"
summary: "python config"
tags: ["docs"]
---

## Install python

In Windows,

```powershell
choco install python
```

In Debian,

```bash
sudo apt install python
```

In Arch,

```bash
sudo pacman -S python
```

## Install neovim package

```bash
pip install -g neovim
```

## Install LSP

```bash
:MasonInstall python-language-server
:MasonInstall pyright
```

## virtual envy

Linux

```bash
source ./.venv/bin/activate
```

Windows

```bash
./.venv/Scripts/activate.ps1
```
