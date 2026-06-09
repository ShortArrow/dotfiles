# pathlint

`pathlint.toml` for this host. Used by
[ShortArrow/pathlint](https://github.com/ShortArrow/pathlint) when
invoked from this directory (or from any descendant via upward
search).

## Capturing a dogfood snapshot

`pathlint lint --json` and `pathlint doctor --json` output is kept
**local only** — too large and too host-specific (PATH entries
include user-profile paths) to track in dotfiles. Capture into a
gitignored or out-of-repo location when needed:

```pwsh
cd V:\dotfiles\pathlint
pathlint lint   --json | Out-File -Encoding utf8 "$HOME\pathlint-lint-$(Get-Date -Format yyyy-MM-dd).json"
pathlint doctor --json | Out-File -Encoding utf8 "$HOME\pathlint-doctor-$(Get-Date -Format yyyy-MM-dd).json"
```

Surfaced findings worth upstreaming go to a pathlint GitHub issue
as an attachment / gist, not back into this repo.

## Non-goals

- No auto-load from `$PROFILE`. Manual invocation only.
- No `[[expect]]` rules in `pathlint.toml` yet — minimal-first
  stance.
