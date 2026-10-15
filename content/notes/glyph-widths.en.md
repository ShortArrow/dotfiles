---
title: "Telling Neovim how wide the terminal draws Nerd Font icons"
description: "Neovim computes a character's width from the Unicode East Asian Width property, but the terminal draws whatever width the font gives the glyph. Nerd Fonts place icons where those two disagree. This note explains the setcellwidths declaration in the Neovim config, which of its 9,636 codepoints currently change anything, and why the ranges are wider than the icons in use."
summary: "Why 21 ranges covering 9,636 codepoints are declared single-width, and why only 45 of them make a difference with the current settings."
---

The problem shows up as a misalignment: to the right of an icon in the
statusline, everything is shifted by one column, and the cursor position and
the drawn text disagree for the rest of that line.

It happens because two programs decide the width independently. Neovim
computes how many cells a character occupies from the character's Unicode
East Asian Width property. The terminal draws the glyph in as many cells as
the font specifies. For ordinary text the two agree. Nerd Fonts put their
icons in codepoints where they do not, so Neovim lays out the line assuming
one width and the terminal draws another.

## What the declaration covers and what it changes

`nvim/src/lua/my/fonts.lua` uses `vim.fn.setcellwidths()` to declare 21
codepoint ranges, 9,636 codepoints in total, as single width: box drawing,
Powerline symbols, Devicons, Material Design Icons and Codicons.

I counted how many of those codepoints would come out wider than one cell
without the declaration:

```
ambiwidth=single   45 of 9,636
ambiwidth=double   9,456 of 9,636
```

This configuration does not set `ambiwidth`, so Neovim runs with the
default, `single`, and the declaration currently changes the width of 45
characters. All 45 are in `U+2600`–`U+26FF`; Unicode classifies them as East
Asian Wide, but a Nerd Font draws them in one cell. ⛔ and ⚽ are examples.
For a few of them:

```
default        : U+26BD=2 U+26CE=2 U+26D4=2 U+26EA=2 U+26F5=2
after override : U+26BD=1 U+26CE=1 U+26D4=1 U+26EA=1 U+26F5=1
```

The other 9,591 codepoints in the declaration make no difference today.
They start to matter as soon as `ambiwidth=double` is set, which is a
setting people writing Japanese tend to turn on so that box-drawing
characters and ambiguous-width punctuation line up. With that setting,
every one of those icons would be laid out as two cells, and the same
declaration keeps them at one.

## The declaration only informs Neovim

`vim.fn.setcellwidths()` changes Neovim's width calculation and nothing
else. The terminal does not learn about it. So the width to declare is not
the width you would prefer but the width the terminal is already drawing,
because the point is to make Neovim's layout match the terminal's output.

That depends on the font. Nerd Fonts come in a mono variant, where each
icon fits in one cell, and a propo variant, where icons can be wider. This
configuration uses the mono variant, and `blink.cmp` is set to
`nerd_font_variant = "mono"` to match. With a propo font the same
declaration would be wrong in the opposite direction.

## Why whole ranges are declared

The ranges follow the origin of each glyph set rather than the icons that
are actually used:

```lua
-- Devicons
table.insert(cellwidths, { 0xe700, 0xe7c5, 1 })

-- Material Design Icons
table.insert(cellwidths, { 0xf0001, 0xf1af0, 1 })
```

The Material Design Icons range alone covers about 110,000 codepoints, and
only a few dozen of them appear anywhere in this configuration. Declaring
only the ones in use would mean that adding a new icon breaks the layout
again until its codepoint is added to the list. Declaring the whole range
covers every icon the font has in it, including ones that are not used yet.
