---
title: "How Neovim chooses its clipboard command"
description: "Neovim hands clipboard access to an external command, and the right command differs between WSL, Windows, Wayland and X11. This note explains how the configuration picks one, why win32yank needs opposite line-ending flags for copy and paste, and why the Wayland case falls through to X11."
summary: "How the clipboard provider is chosen from the environment, and why the Wayland check is allowed to fail over to X11."
---

Neovim does not access the system clipboard itself. When you yank into the
`+` register, it runs the external commands listed in `vim.g.clipboard`, and
`nvim/src/lua/my/clipboard.lua` decides which commands those are by looking
at the environment.

## The order of checks

The configuration tries the environments in this order and uses the first
one that matches:

```
WSL          → win32yank
Windows      → win32yank
Wayland      → wl-copy / wl-paste
X11          → xclip, or xsel if xclip is missing
```

Under WSL it uses win32yank, a Windows program, rather than a Linux
clipboard tool. The text is usually going to be pasted into a browser or an
editor running on the Windows side, so it has to go into the Windows
clipboard; the Linux clipboard would hold it where nothing reads it.

win32yank is looked for in three places, in order: the scoop shim
directory, the chocolatey bin directory, and finally `PATH`. The scoop path
contains the Windows user name, which the configuration takes from
`WIN_USER` if it is set and from `USERNAME` otherwise.

## Copy and paste need opposite conversions

win32yank is called with different flags in each direction:

```lua
copy  = { exe, "-i", "--crlf" }
paste = { exe, "-o", "--lf" }
```

The Windows clipboard stores line breaks as CRLF and a Neovim buffer stores
them as LF, so the text is converted to CRLF on the way in and back to LF on
the way out. If only one direction were converted, pasted lines in Neovim
would end in `^M`, or line breaks would disappear when the text is pasted
into a Windows application.

## The Wayland check can fall through

Matching the Wayland environment does not settle the choice:

```lua
if os.getenv("WAYLAND_DISPLAY") or session == "wayland" then
  set_wl_clipboard()
  if vim.g.clipboard then return end
end
```

`set_wl_clipboard` only fills in `vim.g.clipboard` when `wl-copy` is
installed. If it is not, the variable stays empty and the X11 branch runs
next. That is intentional: in a Wayland session, `xclip` still works through
XWayland, so stopping at the first environment match would leave a working
option unused.

`wl-copy` is started with `--foreground`. It has to keep running to serve
the copied text to other applications, and by default it detaches itself
from the process that started it. With `--foreground` it stays a child
process of Neovim, so it exits when Neovim does instead of lingering.

On X11 the configuration maps the `+` register to the CLIPBOARD selection
and the `*` register to PRIMARY. X11 has both; PRIMARY is the one that
receives text selected with the mouse.

## Not starting a process for every paste

Every provider sets `cache_enabled = 1`. With that, Neovim keeps the last
text it yanked and pastes it from memory instead of starting the external
command each time. On [this machine](/machine/), where every new process is
scanned before it runs, that setting is the difference between a paste that
is instant and one with a visible delay.
