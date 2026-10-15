---
title: "Finding windows that GlazeWM stopped managing"
description: "GlazeWM hides the windows of an inactive workspace by cloaking them through DWM. When GlazeWM restarts after a crash, a monitor change or presentation mode, the cloak stays and the manager is gone: the window reports itself visible and on screen, but nothing draws it. This note explains how such windows are found, why only the owning process can uncloak one, and how the rescue works for wezterm."
summary: "How windows that lost their window manager are found, and why getting one back depends on the application."
---

The symptom is a window that has vanished. It is not in Alt-Tab, it has no
taskbar entry, and its process is still running.

GlazeWM does not hide the windows of an inactive workspace by moving them
off screen. It cloaks them through DWM. A cloaked window is left out of
desktop composition, but every other property stays as it was: the window
reports itself as visible, it has a rectangle on screen, and it is not
minimised. Bringing it to the top of the z-order does not help, because
z-order is not what hides it.

When GlazeWM starts, it enumerates the windows the shell reports. Cloaked
windows are in that list, but nothing in the list says that GlazeWM was
managing them a moment ago. So after a restart the manager is gone and the
cloak remains.

## What causes it

Restarting GlazeWM deliberately is rare. On this machine, stranded windows
come from three events:

- GlazeWM crashes and starts again.
- A monitor is plugged in or unplugged.
- Presentation mode is switched on or off.

The last two are the same event underneath. When the display layout
changes, GlazeWM rebuilds its idea of which monitors and workspaces exist,
and it builds it from what the shell reports. In that report a cloak is
just a current state; there is no record of who applied it.

Any setting that sends a window to a workspace other than the one being
viewed adds to the number of windows affected, because such a window is
cloaked as soon as it arrives there. The usual source is a `window_rules`
entry that places an application on a particular workspace at startup.

## Only the owning process can remove the cloak

Calling `DwmSetWindowAttribute(DWMWA_CLOAK, 0)` on a window from another
process returns `E_ACCESSDENIED`. Elevation does not change that: GlazeWM
itself runs unelevated as the same user, and it manipulates the cloak
through undocumented shell COM interfaces whose vtable layout changes
between Windows builds. So there is no general way to uncloak a window from
outside. A window can be recovered only if its application offers a way in.

wezterm offers one. Each wezterm GUI process keeps a control socket at
`~/.local/share/wezterm/gui-sock-<pid>`. Setting `WEZTERM_UNIX_SOCKET` to
that path makes `wezterm cli` talk to that specific process. Telling it to
move a pane into a new window makes wezterm create the window itself, and a
window created now has no cloak on it.

`glazewm/rescue-window.ps1` uses that. It collects every pane the process
owns, including panes that were already in a window that was drawn
normally, and moves all of them into the new window. For any other
application, the script prints what it knows and stops: restart the
application, or restart `explorer.exe`, which resets the shell's cloaks on
every window at once.

## Three different meanings of "unmanaged"

The harder part is listing the affected windows rather than recovering
them. The condition "GlazeWM is not managing this window" matches the
broken case and two healthy ones:

| | cloak | immersive | |
|---|---|---|---|
| Stranded | > 0 | no | lost its manager; drawn nowhere |
| Unmanaged but drawn | 0 | — | matches an `ignore` rule in `config.yaml` |
| Suspended UWP app | > 0 | yes | cloaked by the shell, not by GlazeWM |

On [this machine](/machine/) the `ignore` rules cover eleven processes, and
UWP applications are suspended and cloaked by the shell all the time. If the
listing reported all three cases the same way, the one window that needs
attention would be buried among a dozen that do not.

`IsImmersiveProcess` separates the first row from the third. The set of
windows GlazeWM currently manages comes from `glazewm query windows`, and
those handles are subtracted from the full list. The full list comes from
`EnumWindows`, reduced to top-level windows that have a title and are
neither minimised nor tool windows.
