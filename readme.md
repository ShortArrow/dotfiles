# dotfiles

[![Site](https://github.com/ShortArrow/dotfiles/actions/workflows/hugo.yml/badge.svg)](https://github.com/ShortArrow/dotfiles/actions/workflows/hugo.yml)

Configuration for the machines of [@ShortArrow](https://github.com/ShortArrow),
applied the same way on Windows, Linux and macOS. [`dotfm.toml`](dotfm.toml)
declares every tool: where its files sit in this repository and where each
operating system expects them.

## Setting up a machine

[`dotfm`](https://github.com/ShortArrow/dotfm) reads `dotfm.toml` and links the
tools enabled on this machine. The selection is per machine, kept in
`~/.config/dotfm/config.toml`, so a work laptop and a home desktop share one
registry and enable different rows of it.

```sh
ghq get ShortArrow/dotfiles     # or git clone, anywhere
cd <checkout>
dotfm init                      # records this checkout as the root
dotfm add git pwsh starship     # enable what this machine needs
dotfm apply                     # links, then each tool's post-apply steps
dotfm status                    # every link, and whether it is in place
```

`dotfm list` prints every tool with its purpose; `dotfm doctor` runs the
health checks tools declare.

Where `dotfm` is not installed yet, each tool carries `setup.ps1` / `setup.sh`.
They read the same `dotfm.toml` through `lib/_lib.{ps1,sh}` and link only their
own tool, so a fresh machine can bootstrap `git` and `pwsh` before it has Rust:

```sh
./git/setup.sh
./pwsh/setup.ps1
```

A launcher run after `dotfm apply`, or the other way round, changes nothing:
both recognise a link that is already correct.

How a tool is declared, the rules its scripts follow and how to add one are
in [`docs/STRUCTURE.md`](docs/STRUCTURE.md). Each tool's readme is also a page
on [dotfiles.shortarrow.jp](https://dotfiles.shortarrow.jp), mounted from where
it sits; [`docs/SITE.md`](docs/SITE.md) describes the build.

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
| Multiplexers / WM | tmux, zellij, glazewm, hyprland |
| Git stack | git, lazygit, neogit, delta |
| Tool manager | mise (`mise/src/config.toml`) — node, python, go, java, rust-cli, aqua |
| File / nav | yazi, fzf, zoxide, lsd, fd, ripgrep |
| Misc | claude (CLAUDE.md + statusline), runex, ssh, keyd |

Each top-level directory contains the actual config files plus optional `setup.{ps1,sh}` and `doctor.ps1`. The full mapping (which file goes where on which OS) lives in [`dotfm.toml`](dotfm.toml).

## Installing the tools

`dotfm` links configuration; it does not install anything. Installation is split in two, and the halves are not symmetric. **mise** (`mise/src/config.toml`) is authoritative: the machine matches the file. **winget** (`winget/*.txt`) is a list to reinstall from on a fresh Windows box, and describes nothing about this one — `winget import` adds and never removes. See [Package installation layers](docs/STRUCTURE.md#package-installation-layers).

On Windows the PATH itself is declared, in `windows/PATH.txt` and `windows/SYSTEM_PATH.txt`, and applied with `windows/ApplyPath.ps1`. It has a budget — see [The PATH budget](docs/STRUCTURE.md#the-path-budget) before adding tools. `windows/doctor.ps1` reports the current state.

## Branch strategy

`main` only. Topic branches are optional; merge back to `main`.

## License

See [`LICENSE`](LICENSE).
