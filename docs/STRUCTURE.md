# Repository structure

`dotfm.toml` is the registry: one `[tools.<name>]` per tool, declaring which
files in this repository go where on each operating system, and any step that
runs after the links exist. Two programs read it. `dotfm` applies the tools
enabled on this machine; `<tool>/setup.ps1` and `<tool>/setup.sh` apply one
tool each through `lib/_lib.{ps1,sh}`, for a machine that has no `dotfm` yet.

## Layout

```
dotfiles/
├── dotfm.toml                 the registry
├── lib/
│   ├── _lib.ps1               symlinks, a TOML subset and logging, for setup.ps1
│   ├── _lib.sh                the same surface for setup.sh
│   └── readme.md              function reference
├── docs/
│   ├── STRUCTURE.md           this file
│   └── SITE.md                how the site is built from this repository
├── <tool>/                    one directory per tool: its files and its readme,
│   ├── setup.ps1              plus the optional per-tool launchers
│   └── setup.sh
├── mise/src/config.toml       tools and runtimes mise installs
├── winget/*.txt               Windows applications to reinstall from
├── windows/
│   ├── PATH.txt               declared user PATH, one entry per line
│   ├── SYSTEM_PATH.txt        declared machine PATH; admin to apply
│   ├── ApplyPath.ps1          writes the two files into the registry
│   ├── DiffPath.ps1           registry PATH against the declared file
│   ├── path-order.toml        ordering rules between PATH entries
│   ├── Test-PathOrder.ps1     checks the process PATH against those rules
│   ├── Test-SupplyChain.ps1   guards on the tool installers
│   ├── Sync-MiseBinFarm.ps1   rebuilds the symlink farm after a mise install
│   ├── doctor.ps1             commands, PATH order and PATH headroom
│   ├── Resize-VirtualDrive.ps1  grows the Dev Drive VHDX
│   └── ics.ps1                Internet Connection Sharing, interactively
└── config/ content/ layouts/ assets/ i18n/ static/   the site — docs/SITE.md
```

## Declaring a tool

A tool declares what it needs in `dotfm.toml`, in the lightest of four shapes:

| Shape | Declares | For |
|---|---|---|
| `[[tools.<name>.links]]` | a file or directory in the repository and its destination per OS | a setting the application reads in place — the default |
| `[[tools.<name>.post_apply]]` | one command, as an argument list | a side effect once the links exist: `git config --global …` |
| `[tools.<name>.script]` | a script per OS | a side effect with branching or discovery: an installer verified by hash, a generated file |
| `[tools.<name>.doctor]` | a script per OS | a read-only health check |

Links are declared once, in `dotfm.toml`; a `script` creates none of its
own. Where a program refuses to follow a symlink, the tool generates the file
inside its `script` and its readme says so — `glazewm/` is the example.

## The per-tool launchers

A tool whose declaration is only `links` carries two three-line launchers:

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

A tool whose work is only a side effect calls the library helpers directly;
`git/setup.{ps1,sh}`, `bash/setup.sh`, `tmux/setup.sh`, `keyd/setup.sh` and
`clink/setup.ps1` are the current ones. Logic beyond that belongs in
`dotfm.toml`, as `script` or `post_apply`.

## Rules for scripts

These hold for `script`, `post_apply` and the launchers alike.

1. **An installer is downloaded to a file, verified against a SHA-256 kept in
   the script, then run.** `tmux/setup.sh` is the pattern. `nvim-rescue/`
   went further and carries the configuration itself, so it installs offline.
2. **A script that needs root checks `EUID` before it changes anything.**
   `keyd/setup.sh`.
3. **Shell rc files are appended to, once, through `append_unique_line`.** A
   launcher may print the `source` line for `$PROFILE`; the user adds it.
4. **A file in the way of a link is kept as `<dst>.bak.<timestamp>`**, by
   `New-DotfileSymlink` and `new_dotfile_symlink`.
5. **Every upstream artifact is pinned by hash**, in the script or through an
   environment variable whose absence fails loudly.

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

## Adding a tool

1. Make the tool's directory and put its files there.
2. Declare it in `dotfm.toml`: `[tools.<name>]`, its `links`, and any
   `post_apply`, `script` or `doctor` it needs.
3. Add the two launchers from the templates above when the tool should be
   reachable on a machine without `dotfm`.
4. `dotfm add <name>`, `dotfm apply <name>`, then `dotfm status`. Run the
   launcher afterwards: it reports every link as already in place.
5. Extend this file when the tool needs a shape it does not describe.

## Moving a tool's link target

A link is removed by the path it was created at, so the old destination is
released before the registry changes:

1. `dotfm remove <name>` — deletes the tool's links at their current
   destinations and disables the tool.
2. Edit `dst.<os>` in `dotfm.toml`.
3. `dotfm add <name>` and `dotfm apply <name>`.

The launchers read the edited entry on their next run.
