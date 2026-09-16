---
title: "How much room is left in PATH on Windows"
description: "cmd.exe can expand an environment variable to at most 8,191 characters. On this machine mise adds about 4,500 characters to PATH whenever it runs a tool, so the persistent PATH has to stay short. This note gives the measured numbers and explains why running out looks like a missing command."
summary: "Why the persistent PATH is kept short, and how much room the measurement says is left."
---

`cmd.exe` expands an environment variable to at most 8,191 characters.
When `PATH` is longer than that, cmd does not truncate it and warn. It
stops finding anything through `PATH` at all, and every command fails with

```
'x' is not recognized as an internal or external command
```

That message is the same one you get for a program that is not installed,
which is misleading here: the executable is on disk, and cmd never looked
for it.

## Why cmd matters on a machine that uses PowerShell

I never open `cmd` interactively, but it still runs during ordinary work:

- npm and pnpm run their package scripts through `cmd`.
- Node's `child_process` uses `cmd` by default.
- Anything started by those two inherits the same behaviour.

So a build that works when run from the terminal can fail inside a package
script for no reason other than the length of `PATH`.

## Where the characters go

The persistent `PATH`, the one stored in the registry, is not the number
that matters. When mise runs a tool, it first prepends the bin directory of
every tool it manages, and that expanded `PATH` is what has to fit in
8,191 characters.

Measured on [this machine](/machine/) on 2026-08-04:

| | |
|---|---|
| Persistent `PATH` | 2,932 characters, 60 entries |
| `PATH` as seen under a mise shim | 7,392 characters |
| Added by mise | 4,460 characters |
| Remaining before the limit | 799 characters |

The persistent part is about two fifths of the total, and mise accounts for
the rest. The mise part grows every time a tool is added. The persistent
part is the only part that is written by hand, so it is the only part I can
keep short.

## What is worth removing

Every entry removed from the persistent `PATH` gives its length back as
headroom. The entries worth removing are the ones that are never actually
used: a directory whose commands are all provided by a mise shim that comes
earlier in `PATH`, or a tool that has since been moved under mise and still
has its old directory listed. Those entries take up length and never
resolve anything.

`windows/path-order.toml` declares which entries must come before which,
and `windows/doctor.ps1` checks both that order and the remaining budget
every time it runs.

## How much room that is

799 characters is enough for roughly eight more tool directories. When the
budget runs out, the first sign will be a package script that cannot find
`node`.
