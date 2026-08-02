---
title: "レジスタは 1 つ、外の実装は 5 つ"
description: "`+` に yank したものがどこへ行くかは、WSL か Windows か Wayland か X11 かで別々のコマンドが決める。同じツールに、コピーとペーストで逆の改行変換を頼む必要もある。"
summary: "clipboard プロバイダを環境から選ぶ順番と、Wayland だけ 2 段構えになっている理由。"
---

`"+y` の行き先は Neovim が決めません。`vim.g.clipboard` に書いた外部コマンドが
決めます。`nvim/src/lua/my/clipboard.lua` はそれを環境から選びます。

## 判定の順番

```
WSL          → win32yank
Windows      → win32yank
Wayland      → wl-copy / wl-paste
X11          → xclip、無ければ xsel
```

WSL で win32yank を使うのは、そこで欲しいクリップボードが Windows のものだから
です。Linux 側のクリップボードへ入れても、貼る先のブラウザやエディタは Windows
側にいます。

win32yank の場所は 3 通り試します。scoop の shim、chocolatey の bin、最後に
`PATH`。scoop のパスにはユーザー名が要るので、`WIN_USER` か `USERNAME` から
組み立てます。

## 同じツールに逆の変換を頼む

win32yank の呼び方が方向ごとに違います。

```lua
copy  = { exe, "-i", "--crlf" }
paste = { exe, "-o", "--lf" }
```

Windows のクリップボードは改行を CRLF で持ち、Neovim のバッファは LF で持ちます。
入れるときに CRLF へ、出すときに LF へ。片方だけにすると、貼り付けた行の末尾に
`^M` が残るか、Windows 側のアプリで改行が消えます。

## Wayland だけ 2 段構え

Wayland の判定に当たっても、そこで終わりません。

```lua
if os.getenv("WAYLAND_DISPLAY") or session == "wayland" then
  set_wl_clipboard()
  if vim.g.clipboard then return end
end
```

`wl-copy` が入っていなければ `vim.g.clipboard` は空のままで、そのまま X11 の
判定へ落ちます。Wayland セッションでも XWayland 経由で `xclip` は動くので、
ここで止めると使えるものを使わずに終わります。

`wl-copy` には `--foreground` を付けています。wl-copy は選択内容を配り続ける
ために動き続ける必要があり、既定では自分を切り離してバックグラウンドへ回ります。
`--foreground` なら Neovim が起動した子プロセスのまま残るので、寿命が Neovim の
管理下に入ります。

X11 側は `+` を CLIPBOARD、`*` を PRIMARY に割り当てます。X11 にはこの 2 つが
別々に存在していて、マウスで選択した内容が入るのが後者です。

## 毎回起動しない

どのプロバイダにも `cache_enabled = 1` を付けています。Neovim が最後に yank した
内容を覚えていて、ペーストのたびに外部プロセスを起動しなくなります。
[プロセス生成に検査が入る環境](/ja/machine/)では、この 1 行がそのまま体感差に
なります。
