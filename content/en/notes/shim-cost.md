---
title: "Launching mise tools without the shims"
description: "A mise shim is three process creations, and a console process that stays between the terminal and the tool for the whole run. Here that turned a 15 ms tool into 127 ms and left bat unable to hand the prompt back."
summary: "Why mise-managed tools are launched through symlinks here, and which ones cannot be."
---

`bat` printed the file and the prompt never came back. `zi` changed
directory and printed nothing. Ctrl-C returned the shell both times.

The binaries were not at fault. Launched directly, both behaved.

## A shim is three processes

`mise\shims\bat.exe` is not bat. It is a small program that starts mise,
which works out which bat this directory should get, and starts that one.
Three process creations answer one command.

Every creation is inspected, because [the machine](/machine/) runs
centrally managed endpoint protection. Fifteen runs of `bat --version`:

| launched through | |
|---|---|
| the shim | 127 ms (115–144) |
| a symlink to the executable | 15 ms (11–28) |

Fifteen milliseconds is the tool. The rest is the arrangement around it.

## It also stays in the middle

Latency does not explain a prompt that never returns. A shim does not hand
over and exit. It remains for the whole run as a console process between
the terminal and the tool, and both of the commands that broke are
conversations with the console: `bat` hands paging to `less`, and `zi`
writes a directory for the shell to read back. Each of those crossed an
extra process that was never built to relay it.

## Why not `mise activate`

`mise activate` moves the resolution into the shell. A hook runs at every
prompt and rewrites `PATH` to the tools the current directory should see.
Nothing relays anything, and no shim is in the way.

That hook is `mise hook-env`, which is itself one more process creation —
130 ms here, at every prompt, whether or not the next command is a mise
tool at all. It also expands `PATH` to 7,265 characters against a limit of
8,191, and the [PATH budget](/notes/path-budget/) has other plans for the
remainder.

## The farm

`%LocalAppData%\mise\bin` holds one symlink per tool, pointing at the real
executable. One process, one 43-character `PATH` entry, no hook.

`windows/Sync-MiseBinFarm.ps1` builds it from the shim directory. Of 204
shims it links 144 and skips the rest:

- 44 by name. Python and pip find the standard library relative to their
  own executable, so through a symlink they would look inside the farm and
  find nothing. The rust family is already reachable from `~/.cargo/bin`.
- 10 whose target is not a PE file. A link named `npm.exe` pointing at a
  `.cmd` is something the loader refuses; the eight extensionless targets
  are the same problem without an extension to give it away.
- 6 that mise no longer resolves.

Those sixty keep their shims and keep working.

## The link goes stale

A symlink names one path, and an upgrade moves the install directory out
from under it. So the farm is the one part of this that needs maintenance,
and three things carry it:

- The PowerShell profile runs the sync at shell start.
- `windows/doctor.ps1` counts links whose target no longer exists.
- `windows/path-order.toml` asserts that the farm resolves before the
  shims, so a tool with no link falls through to the slow path rather than
  failing.
