# pathlint

`pathlint.toml` declares where each command must resolve from on this
host, for [ShortArrow/pathlint](https://github.com/ShortArrow/pathlint).
`windows/doctor.ps1` runs `pathlint check` against it.

A rule names the outcome — the directory the winning binary lives in —
not the order of PATH entries, so moving an entry without changing what
wins passes, and a command that resolves from the wrong place fails even
when the entries look in order.

```pwsh
pathlint --config pathlint/pathlint.toml check
Invoke-Pester pathlint/pathlint.Tests.ps1
```

`pathlint.Tests.ps1` builds fake `%LocalAppData%` and `%ProgramFiles%`
trees and shows each rule passing and failing; it is skipped when
pathlint is not installed.

## Capturing a dogfood snapshot

`pathlint lint --json` and `pathlint doctor --json` output is kept
**local only** — too large and too host-specific (PATH entries
include user-profile paths) to track in dotfiles. Capture into a
gitignored or out-of-repo location when needed:

```pwsh
cd V:\github.com\ShortArrow\dotfiles\pathlint
pathlint lint   --json | Out-File -Encoding utf8 "$HOME\pathlint-lint-$(Get-Date -Format yyyy-MM-dd).json"
pathlint doctor --json | Out-File -Encoding utf8 "$HOME\pathlint-doctor-$(Get-Date -Format yyyy-MM-dd).json"
```

Surfaced findings worth upstreaming go to a pathlint GitHub issue
as an attachment / gist, not back into this repo.

## Non-goals

- No auto-load from `$PROFILE`.
