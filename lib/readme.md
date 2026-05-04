# lib/

Shared helpers for `<tool>/setup.ps1` and `<tool>/setup.sh`.

The single source of truth for **what** to symlink lives in
[`../dotfm.toml`](../dotfm.toml). These libraries let the legacy
`setup.*` scripts replay the same symlink layout when `dotfm` (the
Rust binary) isn't available — for example on a fresh machine before
Rust is installed.

`dotfm apply` and `setup.*` produce the same symlinks; running both
is safe (the second one becomes a no-op).

## Files

| file | for | sourced by |
|------|-----|-----------|
| `_lib.ps1` | PowerShell 5.1+ | `<tool>/setup.ps1` |
| `_lib.sh`  | Bash 4+         | `<tool>/setup.sh`  |

Both implement the same minimal TOML subset for `dotfm.toml`:

- `[tools.<name>]` sections
- `[[tools.<name>.links]]` array entries
- `src = "<path>"` or `src = { dir = "<path>", include = ["a", "b"] }`
- `dst.windows = "..."` / `dst.linux = "..."`
- `platforms = ["windows", "linux"]`

Anything richer (nested arrays, escape sequences, multiline strings)
is the responsibility of the dotfm Rust binary; the libraries abort
with a clear error rather than silently misbehaving.

## PowerShell API (`_lib.ps1`)

```powershell
. "$PSScriptRoot/../lib/_lib.ps1"

Write-DotfileInfo  "starting"
Write-DotfileOk    "all good"
Write-DotfileWarn  "watch out"
Write-DotfileError "broken"

Test-WindowsSymlinkCapable          # true if Dev Mode or Admin

Expand-DotfileVars '$APPDATA/Code/User'
# -> C:\Users\who\AppData\Roaming/Code/User

New-DotfileSymlink -Source 'V:/dotfiles/runex/config.toml' `
                   -Destination "$env:USERPROFILE/.config/runex/config.toml"
# -> 'created' | 'replaced' | 'noop'

Read-DotfileRegistry -Path V:/dotfiles/dotfm.toml
# -> hashtable: name -> @{ platforms; links }

Set-DotfileLinks -ToolName 'alacritty'
# Reads dotfm.toml and ensures every link the tool declares for Windows.
```

## Bash API (`_lib.sh`)

```bash
source "$(cd -P "$(dirname "$0")"/.. && pwd)/lib/_lib.sh"

dotfile_info  "starting"
dotfile_ok    "all good"
dotfile_warn  "watch out"
dotfile_error "broken"

dotfile_os                                 # linux | macos | windows | unknown

expand_dotfile_vars '$XDG_CONFIG_HOME/runex/config.toml'
# -> /home/who/.config/runex/config.toml

new_dotfile_symlink "$src" "$dst"
# echoes 'created' | 'replaced' | 'noop'

read_dotfile_registry V:/dotfiles/dotfm.toml runex linux
# emits TSV: <kind> <path-or-dir> <include-csv> <dst>

set_dotfile_links alacritty
# Looks up alacritty in ../dotfm.toml and ensures every linux link.

append_unique_line ~/.bashrc 'source ~/dotfiles/bash/src/bash_myplug.sh'
# Appends only if the exact line is not already present.
```

## Idempotency / backups

`new_dotfile_symlink` (and its PowerShell twin) treats existing
destinations as follows:

- **Already a symlink to the same source** → no-op.
- **Symlink to a different target** → removed and recreated.
- **Regular file or directory** → moved to `<dst>.bak.<timestamp>`,
  then a fresh symlink is created. The backup is never deleted.

This keeps `setup.*` safe to re-run even after a user has hand-edited
the destination.

## Security posture

The shared library exists partly to centralise the rules below.
Individual `setup.*` scripts must not bypass them:

- **No `curl | bash`.** Download to a tempfile, verify SHA-256, then
  run.
- **Privilege checks come first.** Scripts that need root (e.g.
  `keyd`) must check `EUID` and exit before doing anything.
- **No `$PROFILE` / shell-rc overwrites.** Append-only, with a
  uniqueness guard (`append_unique_line`).
- **Destructive operations announce themselves.** Use `dotfile_warn`
  before backing things up; never silently delete user data.

See [`../docs/STRUCTURE.md`](../docs/STRUCTURE.md) for how this fits
together with the rest of the repo.
