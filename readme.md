# dotfiles

[![Deploy Hugo site to Pages](https://github.com/ShortArrow/dotfiles/actions/workflows/hugo.yml/badge.svg)](https://github.com/ShortArrow/dotfiles/actions/workflows/hugo.yml)

Cross-platform dotfiles of [@ShortArrow](https://github.com/ShortArrow). Same end state on Windows / Linux / macOS via a single source of truth (`dotfm.toml`).

## How it works

Two parallel layers produce the same symlink tree — pick whichever is bootstrappable on the host:

1. **[`dotfm`](https://github.com/ShortArrow/dotfm)** — small Rust binary, reads `dotfm.toml` and applies the link rules. Recommended for everyday use.
2. **`<tool>/setup.ps1` / `<tool>/setup.sh`** — bootstrap launchers used when `dotfm` isn't available yet (fresh boxes, no Rust). They consume the same `dotfm.toml` through `lib/_lib.{ps1,sh}`.

Running both is a no-op the second time. See [`docs/STRUCTURE.md`](docs/STRUCTURE.md) for the full design (decision matrix for `symlink` / `copy` / `post_apply` / `script`, security rules, how to add a tool).

## Quick start

The everyday flow is `dotfm apply`. The `<tool>/setup.{ps1,sh}` launchers exist as **per-tool** fallbacks for hosts where `dotfm` isn't installed yet — each one only touches its own tool.

### With dotfm (recommended)

```bash
# Install dotfm (https://github.com/ShortArrow/dotfm), then:
git clone https://github.com/ShortArrow/dotfiles.git ~/dotfiles
cd ~/dotfiles
dotfm apply       # apply every tool listed in dotfm.toml
dotfm status      # verify the symlinks are in place
```

Windows is the same — clone, `cd`, `dotfm apply` from PowerShell.

### Without dotfm (per-tool bootstrap)

When you can't install Rust yet, run only the tools you need. Each script is idempotent.

```bash
./bash/setup.sh
./git/setup.sh
./tmux/setup.sh
# ...
```

```pwsh
.\pwsh\setup.ps1
.\git\setup.ps1
.\glazewm\setup.ps1
# ...
```

### Docker quick test

```bash
git clone https://github.com/ShortArrow/dotfiles.git
cd dotfiles
docker compose up -d --build
docker compose exec nvim /bin/bash -c nvim
```

## What's inside

| Area | Tools |
| --- | --- |
| Shells / prompt | bash, pwsh, clink, starship |
| Terminals | wezterm, alacritty, windows-terminal |
| Editors | neovim (`nvim/src/`), vim, vscode, zed |
| Multiplexers / WM | tmux, zellij, glazewm, hyprland, i3wm |
| Git stack | git, lazygit, neogit, git-foresta |
| Tool manager | mise (`mise/src/config.toml`) — node, python, go, java, rust-cli, aqua |
| File / nav | yazi, fzf, zoxide, lsd, fd, ripgrep |
| Misc | claude (skills + statusline), runex, ssh, keyd |

Each top-level directory contains the actual config files plus optional `setup.{ps1,sh}` and `doctor.ps1`. The full mapping (which file goes where on which OS) lives in [`dotfm.toml`](dotfm.toml).

## Branch strategy

`main` only. Topic branches are optional; merge back to `main`.

## License

See [`LICENSE`](LICENSE).
