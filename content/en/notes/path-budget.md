---
title: "The PATH budget"
description: "Windows has 8191 characters for PATH, mise spends most of them, and running out breaks commands that are installed and on disk."
summary: "Why the persistent PATH is kept short, and how much room is actually left."
---

`cmd.exe` expands an environment variable to at most **8191 characters**.
Past that it does not truncate loudly — it resolves nothing from `PATH`,
and every command reports

```
'x' is not recognized as an internal or external command
```

which reads as *not installed*. The binary is on disk. The lookup never
happened.

## Why cmd matters on a machine that uses PowerShell

Nothing here runs `cmd` interactively, and it is still in the path of
ordinary work:

- npm and pnpm run-scripts execute through it
- Node's `child_process` defaults to it
- so does anything those two call in turn

A build that works in the terminal can fail inside a package script for
this reason alone.

## Where the characters go

`PATH` at rest is not the number that matters. mise prepends the bin
directory of every managed tool when it runs something, and that
expansion is charged to the same 8191.

Measured on this machine:

| | |
|---|---|
| Persistent `PATH` | 2,858 chars across 58 entries |
| Under a mise shim | **8,006** |
| Added by mise | +5,148 |
| Remaining | **185** |

The persistent path is a fifth of the total. mise is the rest, and it
grows with each tool added — which makes the persistent side the only
part worth defending, because it is the only part that is hand-written.

## What that buys

Every entry removed from the persistent `PATH` is a character of headroom
returned. The ones worth removing are the ones that were never reachable:
a directory that a shim earlier in the order already answers for, or a
tool that has since moved under mise. Those cost length and resolve
nothing.

`path-order.toml` declares the order rules, and `windows/doctor.ps1`
checks both the order and the remaining budget on every run, so the
number above is not something anyone has to remember to measure.

## How much room is left

185 characters is roughly two more tool directories. Adding several more
mise-managed tools crosses the line, and the failure arrives as a package
script that cannot find `node`.
