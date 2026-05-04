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
    └── doctor.ps1             # Health checks (PATH order, cmd presence, ...)
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
`lunarvim/setup.sh`, `clink/setup.ps1` for current examples.

## Security & maintenance rules

These rules apply equally to `dotfm`'s `script`/`post_apply` paths
and the `setup.*` launchers.

1. **No `curl | bash`.** Download to a tempfile, verify SHA-256,
   then run. See `lunarvim/setup.sh` for the canonical pattern.
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
