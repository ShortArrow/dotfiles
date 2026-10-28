# herdr

[`config.toml`](config.toml) is linked to `$APPDATA/herdr/config.toml` by the
dotfm tool `herdr`.

## Logon takeover

A saved machine reconnects over SSH as soon as this one boots, often before
anyone logs on, and the reconnect starts the herdr server under sshd: in
session 0, elevated. That server cannot read symlinks, refuses the desktop
client with Access denied, and has no GUI. At logon,
[`Start-HerdrDesktopServer.ps1`](Start-HerdrDesktopServer.ps1) ends it and
starts the server again in the desktop session, unelevated, until one answers
`herdr status server`.

[`Register-HerdrDesktopServer.ps1`](Register-HerdrDesktopServer.ps1)
registers the two tasks this needs. Its docstring says why there are two and
why the elevated one holds no script.

| Task | Runs | Elevated |
|---|---|---|
| `herdr-desktop-server` | at logon: `Start-HerdrDesktopServer.ps1` | no |
| `herdr-stop-ssh-server` | on demand: `taskkill` of every `herdr.exe` in session 0 | yes |

The tasks call the scripts in this checkout, so a `git pull` changes what
they run without registering again. A change to the registration itself —
action, trigger, settings — needs it run again, from an elevated shell:

```powershell
sudo pwsh -NoProfile -File ./herdr/Register-HerdrDesktopServer.ps1
```

Each logon appends a line to `%LOCALAPPDATA%\herdr\desktop-server.log`. A
takeover that worked ends with `Done after N takeover(s) in session 1`.

Remove with `schtasks /delete /tn <task> /f`.

## Priority

Both tasks run at priority 4, Normal. The scheduler's default is 7,
BelowNormal, and the server inherits the task's class, as does every pane
under it. At BelowNormal a build at Normal priority starves herdr, and the
UI freezes until the build ends.

The class is read when the task starts, so registering again changes the
next logon, not the server already running. To raise that one now:

```powershell
(Get-ScheduledTask herdr-desktop-server, herdr-stop-ssh-server).Settings.Priority   # 4 4
Get-Process herdr | Select-Object Id, SessionId, PriorityClass
(Get-Process -Id <server pid>).PriorityClass = 'Normal'
```

Lowering or raising up to Normal needs no elevation. Panes started before
the change keep the class they inherited.

## Tests

```powershell
Invoke-Pester ./herdr/HerdrServer.Tests.ps1
```
