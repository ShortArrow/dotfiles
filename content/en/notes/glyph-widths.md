---
title: "One icon, and every column after it is off"
description: "The width Neovim computes comes from the Unicode East Asian Width property. The width the terminal paints comes from the font. Nerd Fonts put glyphs where those two disagree, and setcellwidths is where the font's answer is written down."
summary: "Why 21 ranges covering 9,636 codepoints are declared single-width, and why only 45 of them are doing anything today."
---

A column of drift appears to the right of an icon in the statusline. The
cursor and the screen stop agreeing, and they never recover on that line.

Two widths are decided separately. Neovim computes one from the Unicode
East Asian Width property. The terminal paints however many cells the font
says. Nerd Fonts put their glyphs exactly where those two answers differ.

## How much of it is real

`nvim/src/lua/my/fonts.lua` declares 21 ranges — 9,636 codepoints — as
single width: box drawing, Powerline, Devicons, Material Design Icons,
Codicons.

Counting how many of those need the declaration to come out at width 1:

```
ambiwidth=single   45 of 9,636
ambiwidth=double   9,456 of 9,636
```

This configuration never sets `ambiwidth`, so it runs at the default
`single`, and the list is currently earning 45 characters. All 45 sit in
`U+2600`–`U+26FF` and are classified East Asian Wide by Unicode — ⛔ and ⚽
and their neighbours, which a Nerd Font draws in one cell.

```
default        : U+26BD=2 U+26CE=2 U+26D4=2 U+26EA=2 U+26F5=2
after override : U+26BD=1 U+26CE=1 U+26D4=1 U+26EA=1 U+26F5=1
```

The other 9,591 are insurance. They start mattering the moment
`ambiwidth=double` is set — which is what writing Japanese pushes you
towards, for box drawing and ambiguous-width punctuation. The icons all
become two cells wide on the same keystroke.

## It only tells Neovim

`vim.fn.setcellwidths()` overrides Neovim's calculation and nothing else.
The terminal is never informed. So the number to declare is not the width
you would like — it is **the width the terminal is already painting**.

Nerd Fonts come in mono and propo variants, and mono is the one that fits
an icon into a single cell. `blink.cmp` here is set to
`nerd_font_variant = "mono"` to match. On a propo build the same list would
be wrong in the other direction.

## Declared by range

The ranges follow where each glyph set came from rather than which glyphs
are used.

```lua
-- Devicons
table.insert(cellwidths, { 0xe700, 0xe7c5, 1 })

-- Material Design Icons
table.insert(cellwidths, { 0xf0001, 0xf1af0, 1 })
```

Material Design Icons alone is 110,000 codepoints and perhaps a few dozen
of them ever appear. Declaring only the ones in use means the width breaks
again every time an icon is added. Declaring the range covers whatever the
font has filled in, in advance.
