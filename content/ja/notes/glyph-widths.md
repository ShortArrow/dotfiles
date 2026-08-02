---
title: "アイコン 1 個で以降の桁が全部ずれる"
description: "Neovim が計算する文字幅は Unicode の East Asian Width から来る。端末が実際に描く幅はフォントから来る。Nerd Font はその 2 つがずれる位置にグリフを置くので、setcellwidths で font 側の答えを教える。"
summary: "21 レンジ 9,636 文字を幅 1 と宣言している理由と、そのうち今効いているのが 45 文字だけである理由。"
---

ステータスラインのアイコンの右側で、桁が 1 つずれます。カーソルの位置と画面の
表示が食い違い、それ以降ずっと直りません。

原因は 2 つの幅が別々に決まることです。Neovim は Unicode の East Asian Width
プロパティから幅を計算します。端末が実際に何桁ぶん塗るかは、フォントが決めます。
Nerd Font は、この 2 つが一致しない場所にグリフを置いています。

## どれだけずれているか

`nvim/src/lua/my/fonts.lua` は 21 レンジ、合わせて 9,636 文字を幅 1 と宣言して
います。Box Drawing、Powerline、Devicons、Material Design Icons、Codicons。

そのうち、宣言しないと幅 1 にならない文字が何個あるかを数えました。

```
ambiwidth=single   9,636 文字中 45
ambiwidth=double   9,636 文字中 9,456
```

この設定は `ambiwidth` を触っていないので既定の `single` です。つまり今のところ
この一覧が働いているのは 45 文字ぶん。全部 `U+2600`–`U+26FF` にいて、Unicode が
East Asian Wide と分類しているものです。⛔ や ⚽ の類が、Nerd Font では 1 桁で
描かれます。

```
default        : U+26BD=2 U+26CE=2 U+26D4=2 U+26EA=2 U+26F5=2
after override : U+26BD=1 U+26CE=1 U+26D4=1 U+26EA=1 U+26F5=1
```

残り 9,591 文字は保険です。`ambiwidth=double` にした瞬間に効きはじめます。
日本語を書いていると罫線や約物のために double にしたくなるので、そのとき
アイコンが全部 2 桁になって崩れる、という順序で踏みます。

## 教える先は Neovim だけ

`vim.fn.setcellwidths()` が上書きするのは Neovim の計算だけです。端末には何も
伝わりません。だから宣言する値は「こうしたい幅」ではなく「**端末が既にそう
描いている幅**」です。

Nerd Font には mono と propo の 2 系統があり、mono はアイコンを 1 セルに収める
ほうです。この設定の `blink.cmp` も `nerd_font_variant = "mono"` を指定して
います。propo を使っているなら、同じ一覧が今度は逆にずれます。

## レンジ単位で書く

コードポイント単位ではなく、Nerd Font の出自ごとにレンジで書いてあります。

```lua
-- Devicons
table.insert(cellwidths, { 0xe700, 0xe7c5, 1 })

-- Material Design Icons
table.insert(cellwidths, { 0xf0001, 0xf1af0, 1 })
```

Material Design Icons だけで 110,000 文字あり、実際に使うのはそのうち数十です。
使うぶんだけ書くと、アイコンを 1 つ足すたびに幅が壊れます。レンジで宣言して
おけば、フォントが埋めている範囲は先に全部押さえられます。
