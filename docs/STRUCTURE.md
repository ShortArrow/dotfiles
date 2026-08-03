# Repository Structure

This repo manages dotfiles across Windows / Linux / macOS through two
parallel layers that produce the same end state:

1. **`dotfm`** — a small Rust binary (in `V:/dotfm`) that reads
   `dotfm.toml` and creates symlinks. Recommended for everyday use.
2. **`<tool>/setup.ps1` / `<tool>/setup.sh`** — bootstrap scripts
   used when `dotfm` isn't installed yet (fresh machines, or
   machines without Rust). They read the same `dotfm.toml` via
   `lib/_lib.{ps1,sh}` and reproduce the same symlinks.

Either path is safe to run; running both is a no-op the second time.

## Layout

```
dotfiles/
├── dotfm.toml                 # Single source of truth: tool list & link rules
├── lib/                       # Common helpers shared by every setup.ps1/sh
│   ├── _lib.ps1               # PowerShell 5.1+: log/symlink/parser/replay
│   ├── _lib.sh                # Bash 4+: same surface
│   └── readme.md              # Function reference
├── docs/
│   ├── PRD.md                 # Product context (managed externally)
│   ├── TECH.md                # Technology stack (managed externally)
│   └── STRUCTURE.md           # This file
├── <tool>/                    # One directory per tool
│   ├── <config files>         # The actual dotfiles to symlink
│   ├── setup.ps1              # (optional) Windows bootstrap launcher
│   └── setup.sh               # (optional) Unix bootstrap launcher
└── windows/                   # Windows-only utility scripts
    ├── PATH.txt               # Declared user PATH, one entry per line
    ├── SYSTEM_PATH.txt        # Declared machine PATH (needs admin to apply)
    ├── ApplyPath.ps1          # Writes those files into the registry
    ├── path-order.toml        # Ordering rules between PATH entries
    ├── Test-PathOrder.ps1     # Evaluates path-order.toml
    └── doctor.ps1             # Health checks (commands, PATH order, budget)
```

## Decision matrix: symlink / copy / post_apply / script

When adding a new tool, pick the lightest mechanism that fits.

| Mechanism | Use when | Where to declare |
|-----------|----------|------------------|
| **symlink** *(default)* | Setting files live inside the repo. The app reads them directly; edits in either place show up everywhere. | `[[tools.<name>.links]]` in `dotfm.toml` |
| **copy** | The app refuses to follow symlinks, *or* the file is rewritten on every launch and you don't want git noise. | Not currently used. If introduced, add a new dotfm field; do **not** mix copy + symlink in `[[tools.<name>.links]]`. |
| **post_apply** | A side effect that must run *after* the symlink is in place: `git config --global ...`, registering a service, etc. | `[[tools.<name>.post_apply]]` (declarative `run = [...]`) |
| **script** | A side effect that needs branching, dynamic discovery, or an upstream installer (`curl | sha256sum`-then-`bash`, `runex export clink`, scanning for `SKILL.md`, ...). | `[tools.<name>.script]` pointing at `<tool>/setup.ps1` or `setup.sh` |
| **doctor** | Read-only health check, no mutations. | `[tools.<name>.doctor]` pointing at a script |

Rules of thumb:

- Prefer symlink. Falling back to copy must come with a written reason.
- Side effects belong in `post_apply` (declarative) when expressible
  as one shell command; complex logic goes in `script`.
- Never put symlink logic *both* in `[[tools.<name>.links]]` and a
  `script` — pick one. The libraries enforce no-op when the same
  symlink is requested twice, but split sources of truth invite
  drift.

## How `setup.ps1` / `setup.sh` should look

For every tool that has only `[[tools.<name>.links]]`:

```powershell
# <tool>/setup.ps1
. "$PSScriptRoot/../lib/_lib.ps1"
Set-DotfileLinks -ToolName '<tool>'
```

```bash
# <tool>/setup.sh
#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset
script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/_lib.sh"
set_dotfile_links <tool>
```

That's it. Anything more (custom logic, copies, registry edits) is
a sign the tool needs `script` / `post_apply` in `dotfm.toml`
instead of inline imperative code.

For tools whose work is *only* a side effect (no symlinks), the
script just calls `_lib` helpers — see `git/setup.{ps1,sh}`,
`bash/setup.sh`, `tmux/setup.sh`, `keyd/setup.sh`,
`clink/setup.ps1` for current examples.

## Security & maintenance rules

These rules apply equally to `dotfm`'s `script`/`post_apply` paths
and the `setup.*` launchers.

1. **No `curl | bash`.** Download to a tempfile, verify SHA-256,
   then run. See `tmux/setup.sh` for the canonical pattern. Better
   still, avoid the upstream installer: `nvim-rescue/` replaced a
   distribution that needed one with a config the repo carries
   directly, and became reproducible offline as a result.
2. **Privilege checks first.** A script that needs root must check
   `EUID` before mutating anything. See `keyd/setup.sh`.
3. **No `$PROFILE` / shell-rc rewrites.** Append-only with a
   uniqueness guard (`append_unique_line`). `setup.*` may *suggest*
   the user add a `source` line but must not write `$PROFILE`
   itself.
4. **Existing files are backed up, never silently overwritten.**
   `New-DotfileSymlink` / `new_dotfile_symlink` preserve the
   previous content as `<dst>.bak.<timestamp>`.
5. **All upstream artifacts are pinned.** URLs alone are not
   enough; the corresponding SHA-256 must live in the script (or
   be supplied via env var with a clear failure mode).

## Package installation layers

`dotfm` links configuration files; it does not install the tools
themselves. Installation is split by what each manager can reach.

| Layer | Owns | Declared in |
|-------|------|-------------|
| **mise** | CLI tools and language runtimes | `mise/src/config.toml` |
| **winget** | Windows applications, as a list to reinstall from | `winget/public_usecase.txt`, `winget/private_usecase.txt` |

The two are not symmetric, and only one of them describes the machine.

**mise is authoritative.** `mise install` makes the machine match
`config.toml`, and a tool that is not listed is not installed. Removing a
line removes the tool.

**The winget files are a shopping list.** `winget import` installs what the
file names and never removes anything else, so the file can only ever
assert a subset. A package installed by hand stays installed and stays
absent from the list, and no amount of importing changes that. Measured on
2026-08-03: 157 packages installed against 103 declared.

So the list answers one question — what to install on a fresh Windows box —
and does not answer what is on this one. Nothing checks it, because the
only direction a check could enforce is the one `winget import` already
handles.

Rules:

1. **Prefer mise when it has a backend.** One fewer thing installed by
   Windows, one fewer persistent `PATH` entry. This is a preference, not an
   invariant: several tools are currently installed both ways, and nothing
   objects.
2. **`mise` itself and PowerShell cannot move.** PowerShell is the shell
   that activates mise, so routing either through a mise shim is circular.
3. **`public_usecase.txt` is the work and development environment;
   `private_usecase.txt` is hobby and personal apps.** The two sets are
   disjoint, so a private machine imports both:
   `winget/init.ps1 -IncludePrivate`. This split is load-bearing — a work
   machine runs `init.ps1` without the switch and gets none of the second
   file.
4. **Runtime dependencies and OS-bundled apps are not listed.** VCRedist,
   WindowsAppRuntime, UI.Xaml, VCLibs, Edge and OneDrive arrive with their
   dependents, so listing them would install nothing that was not coming
   anyway.
5. **Some packages cannot be listed at all.** Three installed packages
   resolve to no winget source, so `winget import` will never restore them.
   A fresh machine needs those installed by hand whatever the list says.

Both files are `winget import` format, so `winget export` output can be
diffed against them when curating.

## The PATH budget

`PATH.txt` and `SYSTEM_PATH.txt` are the declared PATH; `ApplyPath.ps1`
writes them into the registry. Windows composes the process PATH as
machine-then-user, so a machine entry always shadows a user one — which
is why a tool installed under `Program Files` beats the mise shim for the
same command.

Adding tools is bounded. `cmd.exe` expands an environment variable to at
most 8191 characters, and a mise shim prepends the install directory of
every managed tool, so what matters is not the length of the persistent
PATH but how much room it leaves for that injection. Past the limit cmd
resolves nothing from PATH and reports `'x' is not recognized` for a
binary that is plainly installed. `doctor.ps1` measures the PATH as a
shim sees it and reports the headroom.

Three consequences for maintenance:

1. **Each mise tool costs roughly 100 characters** of injected PATH.
   Migrating a tool from winget to mise removes one persistent entry but
   adds a larger injected one, so migration slightly *increases* the
   total. It is done for version currency, not for budget.
2. **Removing a fully shadowed entry is the one free win.** If every
   executable in a directory is already provided by a mise shim, deleting
   the entry shortens the persistent PATH and changes nothing else.
3. **Prefer taking cmd out of the path.** `js/npmrc` sets
   `script-shell=pwsh` so npm lifecycle scripts never hit the limit at
   all. PowerShell has no equivalent cap.

Three limits are easy to confuse:

| Limit | Value | Applies to |
|-------|-------|------------|
| `setx` truncation | ~1024 chars | Anything shelling out to `setx PATH` |
| Registry value | ~32767 chars | The stored PATH, user or machine alike |
| `cmd.exe` expansion | 8191 chars | `%PATH%` expanded inside cmd |

`ApplyPath.ps1` writes the registry through `Set-ItemProperty` for the
first reason. An installer that calls `setx PATH` on a long PATH silently
truncates it to the first kilobyte — that has happened here, and the
recovery is to re-apply from `PATH.txt`. The machine PATH is not a
relief valve either: both scopes share the same registry ceiling.

winget is the usual source of growth. Portable packages append
`%LocalAppData%\Microsoft\WinGet\Packages\<package>\…` and this cannot be
turned off, so keep only `…\WinGet\Links` — the shims land there — and
drop the versioned package directories. winget also re-appends an entry
in expanded form when the declared one uses `%LocalAppData%`, since it
compares the raw registry string; re-running `ApplyPath.ps1` clears the
duplicate.

## Adding a new tool

1. Create the tool directory and put the config files inside.
2. Add a `[tools.<name>]` block to `dotfm.toml` with the
   appropriate `[[tools.<name>.links]]` (and any `post_apply`,
   `script`, or `doctor` you need).
3. (Optional) Drop in `setup.ps1` / `setup.sh` from the template
   above so the tool stays bootstrappable without Rust.
4. Verify both paths produce identical results:
   - `dotfm apply` → check status with `dotfm status`
   - Run `setup.{ps1,sh}` → confirm no further changes
5. Update this file if the new tool introduces a previously
   undocumented mechanism (e.g. first use of `copy`).

## Updating an existing tool's link target

`dotfm.toml` is the source of truth. Edit the `dst.<os>` entry
there once, and both `dotfm` and the `setup.*` launchers follow.

If the change requires deprecating an old symlink target, leave a
note in the tool's local `readme.md` (or in `dotfm.toml` as a
comment) so future runs of `dotfm` / `setup.*` clean up
gracefully.
