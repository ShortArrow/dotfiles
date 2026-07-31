---
title: "Python"
summary: "python config"
tags: ["docs"]
---

## Install python

In Windows,

```powershell
mise use -g python
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

`pip` has no global-install flag; `uv` (also declared in mise) installs the
package into an isolated environment and exposes its entry points.

```bash
uv tool install neovim
```

## Install LSP

```bash
:MasonInstall python-lsp-server
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
