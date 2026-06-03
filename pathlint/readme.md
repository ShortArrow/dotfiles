# pathlint dogfood

Snapshots of `pathlint doctor --json` captured on real hosts to feed back into [ShortArrow/pathlint](https://github.com/ShortArrow/pathlint).

Run:

```pwsh
cd V:\dotfiles\pathlint
pathlint doctor --json | Out-File -Encoding utf8 "snapshots/windows-pwsh-$(Get-Date -Format yyyy-MM-dd).json"
```

Do not auto-load from `$PROFILE` yet — manual invocation only in Round 1.
