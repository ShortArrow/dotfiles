---
title: "One register, five providers"
description: "Where a yank to `+` ends up is decided by an external command, and which command depends on WSL, Windows, Wayland or X11. The same tool also has to be asked for opposite line-ending conversions in each direction."
summary: "How the clipboard provider is chosen from the environment, and why Wayland gets two attempts."
---

Neovim does not decide where `"+y` goes. The external commands in
`vim.g.clipboard` do, and `nvim/src/lua/my/clipboard.lua` picks them from
the environment.

## The order

```
WSL          → win32yank
Windows      → win32yank
Wayland      → wl-copy / wl-paste
X11          → xclip, or xsel
```

WSL uses win32yank because the clipboard that matters there is Windows'.
Putting the text in the Linux clipboard leaves it where nothing is going to
paste from: the browser and the editor it is headed for are on the Windows
side.

win32yank is looked for in three places — the scoop shim, the chocolatey
bin, then `PATH`. The scoop path needs a username, which comes from
`WIN_USER` or `USERNAME`.

## Opposite conversions from the same tool

win32yank is invoked differently in each direction.

```lua
copy  = { exe, "-i", "--crlf" }
paste = { exe, "-o", "--lf" }
```

The Windows clipboard holds CRLF and a Neovim buffer holds LF. Convert
going in, convert coming out. Do it on one side only and either the pasted
lines carry a trailing `^M` or the line breaks vanish in whatever Windows
application receives them.

## Wayland gets two attempts

Matching Wayland is not the end of it.

```lua
if os.getenv("WAYLAND_DISPLAY") or session == "wayland" then
  set_wl_clipboard()
  if vim.g.clipboard then return end
end
```

With `wl-copy` absent, `vim.g.clipboard` is still empty and the X11 branch
runs next. `xclip` works under XWayland in a Wayland session, so stopping
at the first match would decline something that works.

`wl-copy` is called with `--foreground`. It has to keep running to serve
the selection, and by default it detaches itself into the background;
`--foreground` keeps it the child process Neovim started, so its lifetime
stays under Neovim's control.

On X11, `+` maps to CLIPBOARD and `*` to PRIMARY. X11 has both, and PRIMARY
is the one a mouse selection lands in.

## Not launching it every time

Every provider carries `cache_enabled = 1`. Neovim remembers the last thing
it yanked and stops starting an external process for each paste. On
[a machine that inspects every process creation](/machine/) that one line
is the difference you feel.
