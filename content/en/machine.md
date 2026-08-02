---
title: "The machine"
description: "What the numbers in the notes were measured on, and the two environment facts most of them depend on."
---

The notes quote timings and character counts. They were all taken here.

| | |
|---|---|
| OS | Windows 11 Pro, build 26200 |
| CPU | Intel Core 9 270H, 14 cores / 20 threads |
| Memory | 32 GB |
| System volume | `C:` NTFS, 1.8 TB |
| Work volume | `V:` ReFS, 400 GB, a Dev Drive |
| Shell | PowerShell 7.6 under WezTerm |
| Second environment | Arch on WSL 2 |

The repository is checked out on `V:`, and everything it installs is a
symlink from there.

## Two facts the numbers depend on

**Endpoint protection is centrally managed and inspects every process
creation.** It cannot be turned off, and the inspection is synchronous, so
process creation costs roughly 150 ms rather than the few milliseconds it
would otherwise. Anything that launches one program through another pays
that per hop. On a machine without it, the shim timings in
[Launching mise tools without the shims](/notes/shim-cost/) would be a
fraction of what is written there, and the reason for the whole
arrangement would be much weaker.

**`V:` is a trusted Dev Drive.** ReFS plus the trust flag is what keeps the
antivirus filter off file writes in the working tree. Without the trust
flag the same volume takes about 500 ms per write while Defender scans
synchronously, which is slow enough to make a build feel broken.

Numbers that do not depend on either — `PATH` lengths, the count of shims,
the number of processes a shim starts — hold anywhere the same tools are
installed.
