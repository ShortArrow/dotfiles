# pathlint dogfood

Snapshots of `pathlint lint --json` and `pathlint doctor --json`
captured on real hosts to feed back into
[ShortArrow/pathlint](https://github.com/ShortArrow/pathlint).

## Capturing a Round 2 snapshot (pathlint 0.0.35+)

`lint` and `doctor` were split in 0.0.34 (ADR-0028). Capture both:

```pwsh
cd V:\dotfiles\pathlint
pathlint lint   --json | Out-File -Encoding utf8 "snapshots/windows-pwsh-lint-$(Get-Date -Format yyyy-MM-dd).json"
pathlint doctor --json | Out-File -Encoding utf8 "snapshots/windows-pwsh-doctor-selfcheck-$(Get-Date -Format yyyy-MM-dd).json"
```

`lint` carries the 12 PATH-hygiene detector kinds the 0.0.33
`doctor` used to emit (duplicate, shortenable, missing, shadow,
etc). `doctor` is now a selfcheck — empty array means pathlint is
healthy in this environment.

## Round 1 (pathlint 0.0.33, 2026-06-03)

`windows-pwsh-2026-06-03.json` — 202 diagnostics from
`pathlint doctor --json` on the maintainer's Windows 11 pwsh host.
The 0.0.33 `doctor` covered the surface that 0.0.34 `lint` now
covers; the kind enum is the same.

Headline counts: `duplicate_but_shadowed` 101 / `shortenable` 39 /
`writeable_path_dir` 33 / `missing` 14 / `trailing_slash` 13 /
`relative_path_entry` 1 / `conflict (mise_activate_both)` 1.

## Round 2 (pathlint 0.0.35, 2026-06-09)

`windows-pwsh-lint-2026-06-09.json` — 247 diagnostics from
`pathlint lint --json` on the same host.

`windows-pwsh-doctor-selfcheck-2026-06-09.json` — empty array
(pathlint passes selfcheck cleanly: binary on PATH, pathlint.toml
not required, env_lookup operational).

Kind diff vs Round 1:

| kind | Round 1 | Round 2 | delta |
|---|---|---|---|
| duplicate_but_shadowed | 101 | 147 | +46 |
| shortenable | 39 | 41 | +2 |
| writeable_path_dir | 33 | 34 | +1 |
| missing | 14 | 23 | +9 |
| trailing_slash | 13 | 0 | -13 |
| relative_path_entry | 1 | 1 | 0 |
| conflict (mise_activate_both) | 1 | 1 | 0 |

`trailing_slash` cleared (host PATH was tidied between rounds, not
a detector change). `duplicate_but_shadowed` and `missing`
increases reflect host PATH growth (new tools installed) — the
kind enum and the detector logic are unchanged from 0.0.33.

The 0.0.33 → 0.0.35 comparison is one-way (subcommand name
changed; JSON shape unchanged). Both snapshots stay in git
history for future reference; future rounds add a new
`windows-pwsh-lint-<date>.json` rather than overwriting.

## Non-goals

- No auto-load from `$PROFILE`. Manual invocation only.
- No `[[expect]]` rules in `pathlint.toml` yet — minimal-first
  stance (see Round 1 plan).
- No WSL Arch / Linux snapshots yet — Round 3 candidate.
