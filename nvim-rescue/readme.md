---
title : 'Neovim rescue config'
description: "isolated fallback editor"
summary: "a Neovim config that stays usable when the main one breaks"
tags: ["docs"]
---

# nvim-rescue

A second Neovim configuration for repairing the first one. It is more
capable than falling back to `vi`, and it cannot be affected by whatever
broke `nvim/src`.

```pwsh
nvimr           # alias defined in pwsh/src/pwsh_myplug.ps1
```

```bash
NVIM_APPNAME=nvim-rescue nvim
```

`NVIM_APPNAME` (Neovim 0.9+) redirects both the config directory and the
state directory, so this instance reads `nvim-rescue/` instead of
`nvim/src` and keeps its shada, undo and swap files apart. Neither config
can write into the other. The statusline is marked `RESCUE` so the two
instances are not confused while one of them is being repaired.

## Why it has no plugins

A rescue tool that needs a working plugin manager, a network connection
and a successful bootstrap is a rescue tool that fails exactly when it is
needed. Neovim 0.11 moved enough into core to make plugins unnecessary
here:

| Capability | Provided by |
|---|---|
| LSP configuration | `vim.lsp.config` / `vim.lsp.enable` |
| Completion | `vim.lsp.completion.enable` |
| Syntax | `vim.treesitter.start` with the bundled parsers |

Cloning the repository is the entire install. There is no upstream
installer to pin and no checksum to verify.

## Language servers

Servers are declared in `init.lua` and enabled only when their executable
resolves, so a machine missing any of them starts clean rather than
erroring on every buffer.

| Server | Command |
|---|---|
| lua_ls | `lua-language-server` |
| rust_analyzer | `rust-analyzer` |
| clangd | `clangd` |
| gopls | `gopls` |
| pyright | `pyright-langserver` |
| ts_ls | `typescript-language-server` |

The main config installs its servers through Mason, which puts them in a
directory this config does not read. Anything reachable on PATH — the
mise-managed `rust-analyzer`, LLVM's `clangd` — is picked up here
automatically. Add a server by appending to the `servers` table.

## Keymaps

Deliberately close to stock Neovim: this config is used rarely and under
pressure, so it should not require remembering a second set of habits.

| Key | Action |
|---|---|
| `<leader>e` | Show the diagnostic under the cursor |
| `<leader>q` | Send diagnostics to the location list |
| `<leader>f` | Format the buffer through the LSP |
| `gd` / `K` | Definition / hover |
| `grn` / `gra` / `grr` | Rename / code action / references |
| `<Esc>` | Clear search highlight |

## History

This replaces LunarVim, which filled the same role. Upstream stopped:
the last release was 1.4.0 in May 2024 and there were no commits in the
following year. The local `setup.sh` had also pinned it to the
`neovim-0.8` branch and required a hand-computed SHA-256 before it would
run, which is why it never actually got installed.
