# Font

For a desktop Arch install, where the machine renders its own glyphs.

**Not needed under WSL.** A WSL shell is displayed by WezTerm on the
Windows side, so the glyphs come from the fonts installed on Windows;
installing nerd-fonts inside the distribution only duplicates them.

## repo

<https://archlinux.org/groups/any/nerd-fonts/>

install and refresh

```bash
ln -s "$(git rev-parse --show-toplevel)/archlinux/fontconfig" ~/.config/
fc-cache -f -v
```

The link is manual: this directory has no `dotfm.toml` entry, so
`dotfm apply` does not touch it.
