---
title: "Windows that are visible and drawn nowhere"
description: "GlazeWM hides an inactive workspace by cloaking its windows through DWM. A crash, a monitor plugged in, or presentation mode toggled leaves the cloak without the manager — a window that reports itself visible, on screen, and belonging to no workspace."
summary: "Finding windows a window manager lost, and why recovering one is a per-application problem."
---

A window disappears. Alt-Tab does not bring it back, the taskbar entry is
gone, and the process is still running.

GlazeWM does not move the windows of an inactive workspace off screen. It
cloaks them, through DWM. A cloaked window is excluded from composition
while everything else about it stays true: it is visible, it has an
on-screen rectangle, it is not minimised. Raising its z-order does
nothing, because z-order is not what is hiding it.

Restart GlazeWM and it enumerates what the shell reports. Cloaked windows
are reported, and they arrive with no indication that anyone was managing
them a moment ago. The manager is gone and the cloak is not.

## Nobody restarts it on purpose

A deliberate restart is the rare case. What actually produces stranded
windows here:

- GlazeWM crashes and comes back.
- A monitor is plugged in or unplugged.
- Presentation mode is switched on or off.

The last two are one event underneath. The display layout changes, GlazeWM
works out afresh which monitors and workspaces exist, and it builds that
from what the shell reports — where a cloak is a current state and not a
history of who set it.

Anything that sends a window to a workspace you are not looking at feeds
this, because such a window is cloaked from the moment it lands. A
`window_rules` entry that files an application away on startup is the
usual source.

## Only the owner can uncloak

`DwmSetWindowAttribute(DWMWA_CLOAK, 0)` from another process returns
`E_ACCESSDENIED`. It is not a privilege problem — GlazeWM itself runs
unelevated as the same user, and reaches the cloak through undocumented
shell COM whose vtable layout moves between Windows builds. So there is no
general recovery, and the path back exists only where the application
offers one.

wezterm does. It keeps a control socket per GUI process at
`~/.local/share/wezterm/gui-sock-<pid>`, and pointing
`WEZTERM_UNIX_SOCKET` at it makes `wezterm cli` talk to that process
rather than whichever one it would have picked. Asking it to move a pane
to a new window makes wezterm create the window, and a window created now
carries no cloak.

So `glazewm/rescue-window.ps1` gathers every pane the process owns —
including panes that were already in an uncloaked window — and moves them
all into the new one. For anything else it prints what it knows: restart
the application, or restart `explorer.exe` to reset shell cloaks across
every window at once.

## Unmanaged is three different things

The hard part is the listing rather than the recovery. "GlazeWM is not
managing this window" describes the broken case and two healthy ones:

| | cloak | immersive | |
|---|---|---|---|
| Stranded | > 0 | no | lost its manager, drawn nowhere |
| Unmanaged but drawn | 0 | — | an `ignore` rule in `config.yaml` |
| Suspended UWP | > 0 | yes | the shell's doing, not GlazeWM's |

The ignore rules produce unmanaged windows deliberately, and the shell
cloaks UWP windows when it suspends them. Reporting either as stranded
would bury the one case that matters under a dozen that do not.

`IsImmersiveProcess` separates the first row from the third, and
`glazewm query windows` supplies the handles that are managed right now,
which is what the whole set is subtracted from. Everything else comes from
`EnumWindows` filtered down to titled top-level windows that are neither
minimised nor tool windows.

## Listing is the default

Running the script with no switch lists. Recovery needs `-Rescue`, and
narrowing to one process or handle is available for when the list is long.
A tool that moves panes between windows on its own initiative would be
worse than the problem.
