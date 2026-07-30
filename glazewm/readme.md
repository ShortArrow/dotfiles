# GlazeWM

## How to install

```
winget install glazewm
./glazewm/setup.ps1
```

## Launch on login

Add taskscheduler action


```text
%LocalAppData%\Microsoft\WinGet\Links\glazewm.exe
```

```text
pwsh
-c "$PSStyle.OutputRendering='Ansi'; Start-Process -NoNewWindow 'C:\Users\who\Documents\GitHub\glazewm\target\release\glazewm.exe' -ArgumentList 'start'; pause;"
```

## Stranded windows

GlazeWM hides windows on inactive workspaces by DWM-cloaking them, not by moving
them off-screen: every managed window with `displayState: hidden` reports DWM
cloak value 2, and every `shown` one reports 0.

A GlazeWM restart does not enumerate cloaked windows. A window that sat on an
inactive workspace therefore keeps its cloak while losing its manager, and is
drawn on no workspace at all. It still reports `WS_VISIBLE` and an on-screen
rectangle, so ordinary visibility checks call it healthy, and raising the
z-order does not reveal it — even a transparent window on top of it stays
invisible.

Any `window_rules` entry that relocates windows to a workspace you are not
looking at feeds this: whatever gets moved there is cloaked, and survives a
restart stranded.

List what is stranded:

```powershell
./glazewm/rescue-window.ps1
```

Recover, optionally narrowing to one process or window:

```powershell
./glazewm/rescue-window.ps1 -Rescue
./glazewm/rescue-window.ps1 -Rescue -ProcessId 11268
```

### Why recovery is per-application

`DwmSetWindowAttribute(DWMWA_CLOAK, 0)` fails with `E_ACCESSDENIED` from another
process — a cloak is clearable only by the process that owns the window. This is
not a privilege problem; GlazeWM runs unelevated as the same user and reaches the
cloak through undocumented shell COM whose vtable layout moves between Windows
builds, which is too fragile to reproduce here.

So the script recovers by asking the application to build a fresh window, which
carries no cloak:

- **wezterm** — has a per-process control socket at
  `~/.local/share/wezterm/gui-sock-<pid>`. Every pane the process owns is moved
  into a new window; the emptied original closes itself. Panes keep running, so
  nothing in the session is lost. Note this consolidates *all* of that process's
  panes, including any already in a healthy window.
- **anything else** — reported with no action. Restart the application, or
  restart `explorer.exe` to reset shell cloaks globally. Windows Terminal has no
  CLI for moving tabs between windows, so it falls here.

The listing separates two other groups. Windows that are unmanaged but drawn are
normally the `ignore` rules in `config.yaml` doing their job. Suspended UWP
windows are cloaked by the shell for reasons unrelated to GlazeWM and are
counted only; they are detected with `IsImmersiveProcess`.
