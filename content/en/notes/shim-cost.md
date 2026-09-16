---
title: "Why mise tools are launched through symlinks instead of shims"
description: "A mise shim starts three processes for one command and stays between the terminal and the tool until the tool exits. On this machine that made a 15 ms tool take 127 ms and broke bat and zi. A directory of symlinks to the real executables avoids both problems."
summary: "Why mise-managed tools are launched through symlinks here, and which 60 tools still use their shims."
---

Two mise-managed tools stopped working normally on this machine. `bat`
printed the file, but the prompt did not come back afterwards. `zi`, the
interactive mode of zoxide, changed the directory but printed nothing and
also did not return the prompt. In both cases Ctrl-C brought the shell back.
Running the same executables directly, without going through mise, worked
fine, so the problem was in how the tools were launched.

## What a shim does

`mise\shims\bat.exe` is not bat itself. It is a small program that starts
mise, asks mise which version of bat applies to the current directory, and
then starts that bat. One command therefore creates three processes: the
shim, mise, and the tool.

That matters here because [this machine](/machine/) runs centrally managed
endpoint protection, and every new process is scanned before it runs. I ran
`bat --version` fifteen times through each path:

| launched through | time over 15 runs |
|---|---|
| the shim | 127 ms (115–144) |
| a symlink to the executable | 15 ms (11–28) |

bat itself takes about 15 ms to start. The remaining 112 ms is the scanning
of the two extra processes.

## Why the prompt did not come back

Slowness alone would not explain a prompt that never returns. The second
problem is that the shim does not exit after starting the tool. It stays
running until the tool finishes, so for the whole run there is an extra
console process between the terminal and the tool.

The two tools that broke are the two that talk to the terminal directly.
`bat` pipes its output into `less` for paging, and `zi` prints the chosen
directory to standard output so that the shell function around it can `cd`
there. Both assume that the other end of their standard streams is the
terminal. With the shim in between, that assumption fails, and each of them
waits for something that never arrives.

## Why not `mise activate`

mise's own answer to this is `mise activate`, which does the version
resolution in the shell instead of in a shim. A hook runs before every
prompt and rewrites `PATH` so that the tools for the current directory come
first. Nothing sits between the terminal and the tool.

The hook, `mise hook-env`, is itself a process, so it gets the same scan:
about 130 ms at every prompt, even when the next command has nothing to do
with mise. It also makes `PATH` long. With activation on, `PATH` reached
7,265 characters, and cmd.exe stops resolving commands once `PATH` is longer
than 8,191. The remaining room is needed for other things, which is covered
in [the PATH budget](/notes/path-budget/).

## The symlink directory

What I use instead is a directory, `%LocalAppData%\mise\bin`, containing one
symlink per tool that points at the tool's real executable. Launching a tool
through it creates one process, it adds a single 43-character entry to
`PATH`, and no hook runs at the prompt.

`windows/Sync-MiseBinFarm.ps1` builds the directory by going through the
shims directory and asking mise where each shim resolves to. Of the 204
shims, it links 144 and skips 60:

- 44 are skipped by name. Python and pip locate the standard library
  relative to their own executable, so if they were started through a
  symlink they would look for it inside the symlink directory and not find
  it. The rust tools are skipped because `~/.cargo/bin` is already on
  `PATH`.
- 10 are skipped because the target is not a Windows executable. The shim
  named `npm.exe`, for example, resolves to a `.cmd` file, and the loader
  refuses to run a `.exe` symlink that points at a script. Eight of the ten
  have no extension at all, which fails for the same reason.
- 6 are skipped because mise no longer resolves them to anything.

Those 60 tools keep using their shims. They are slower, but they work.

## Keeping the links valid

A symlink points at one fixed path, and `mise up` changes that path when it
installs a new version: node moves from `tools\node\22.14.0` to `22.15.0`,
and the link to the old directory stops working. So the symlink directory is
the one part of this setup that needs maintenance, and four things take care
of it:

- mise's postinstall hook runs the sync script after every install.
- The PowerShell profile runs the sync script in the background when it
  starts and finds a link whose target is gone.
- `windows/doctor.ps1` reports how many links currently point at a missing
  target.
- `windows/path-order.toml` requires the symlink directory to come before
  the shims directory in `PATH`. A tool without a link falls back to its
  shim, so an upgrade can make a tool slow again but never makes it
  disappear.
