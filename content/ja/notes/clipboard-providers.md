---
title: "Neovim がクリップボード用のコマンドを選ぶ順番"
description: "Neovim はクリップボードの読み書きを外部コマンドに任せていて、その正解は WSL・Windows・Wayland・X11 で違います。設定がどう選んでいるか、win32yank にコピーとペーストで逆向きの改行変換を指定している理由、Wayland の判定で終わらず X11 に落ちる理由をまとめます。"
summary: "クリップボードのプロバイダを環境から選ぶ順番と、Wayland の判定が X11 に引き継がれる理由。"
---

Neovim は自分ではシステムのクリップボードを扱いません。`+` レジスタに yank する
と、`vim.g.clipboard` に登録した外部コマンドが実行されます。どのコマンドを登録
するかは `nvim/src/lua/my/clipboard.lua` が環境を見て決めています。

## 判定の順番

次の順に環境を調べ、最初に当てはまったものを使います:

```
WSL          → win32yank
Windows      → win32yank
Wayland      → wl-copy / wl-paste
X11          → xclip、無ければ xsel
```

WSL では Linux 用のクリップボードツールではなく、Windows のプログラムである
win32yank を使います。yank した文字列は、たいてい Windows 側で動いている
ブラウザやエディタに貼り付けるので、Windows のクリップボードに入れる必要が
あります。Linux 側のクリップボードに入れても、それを読む相手がいません。

win32yank は、scoop の shim ディレクトリ、chocolatey の bin ディレクトリ、
`PATH` の順に探します。scoop のパスには Windows のユーザー名が含まれるので、
`WIN_USER` があればそれを、なければ `USERNAME` を使って組み立てています。

## コピーとペーストで逆向きの変換が要る

win32yank は方向によって別のフラグで呼びます:

```lua
copy  = { exe, "-i", "--crlf" }
paste = { exe, "-o", "--lf" }
```

Windows のクリップボードは改行を CRLF で持ち、Neovim のバッファは LF で持ち
ます。そのため、入れるときに CRLF へ、取り出すときに LF へ変換します。片方だけ
変換すると、Neovim に貼り付けた行の末尾に `^M` が残るか、Windows のアプリに
貼り付けたときに改行が消えます。

## Wayland の判定は X11 に引き継がれる

Wayland の環境に当てはまっても、それで確定ではありません:

```lua
if os.getenv("WAYLAND_DISPLAY") or session == "wayland" then
  set_wl_clipboard()
  if vim.g.clipboard then return end
end
```

`set_wl_clipboard` は `wl-copy` が入っているときだけ `vim.g.clipboard` を設定
します。入っていなければ変数は空のままなので、続けて X11 の判定に進みます。
これは意図した動きです。Wayland のセッションでも XWayland 経由で `xclip` は
動くので、最初に当てはまった環境で打ち切ると、使えるものを使わずに終わって
しまいます。

`wl-copy` には `--foreground` を付けて起動しています。wl-copy はコピーした内容
を他のアプリに渡すために動き続ける必要があり、既定では起動元のプロセスから
切り離されてバックグラウンドに回ります。`--foreground` を付けると Neovim の
子プロセスのままになるので、Neovim を終了したときに一緒に終了し、残り続ける
ことがありません。

X11 では `+` レジスタを CLIPBOARD セレクションに、`*` レジスタを PRIMARY に
割り当てています。X11 にはこの 2 つが別々にあり、マウスで選択した文字列が入る
のは PRIMARY です。

## ペーストのたびにプロセスを起動しない

すべてのプロバイダに `cache_enabled = 1` を設定しています。これがあると Neovim
は最後に yank した内容を覚えておき、ペーストのたびに外部コマンドを起動せず、
記憶している内容を貼り付けます。[このマシン](/ja/machine/)は新しいプロセスの
起動ごとに検査が入るので、この設定があるかないかで、ペーストが一瞬で終わるか
目に見える待ちが入るかが変わります。
