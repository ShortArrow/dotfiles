---
title: "不変条件は 1 か所、走らせ方は 2 通り"
description: "設定は正しいのに Neovim が固まる、という壊れ方がある。原因がリポジトリではなくマシンの状態にあるので、lint では出ない。検査本体を 1 モジュールに置いて、:checkhealth と headless CI の両方から呼んでいる。"
summary: "`:checkhealth my` と headless CI が同じ検査本体を使う理由と、不在を確かめるのに待たなければならない理由。"
---

設定ファイルは正しいのに Neovim が固まる、という壊れ方があります。原因が
リポジトリの外にあるからです。

- mason に C# の言語サーバーが 3 つ入っている。omnisharp、omnisharp-mono、
  csharp-language-server。どれも `.cs` バッファに attach するので、ソリュー
  ションの読み込みが 3 回走り、最初のハイライトが出るまで UI スレッドが止まり
  ます。設定が要求しているのは 1 つだけ。余分に入っているだけです。
- `lsp.log` が数 MB ある。どこかのサーバーが WARN を吐き続けていて、その 1 行
  ずつが編集中に同期で書かれます。
- blink.cmp が InsertEnter より前にロードされている。require に約 1 秒かかる
  ので（[このマシン](/ja/machine/)での話です）、ファイルを開くたびにそのぶん
  待たされます。

どれも lint には出ません。リポジトリの中身は正しくて、外の状態がずれています。

## 検査本体は 1 か所

`nvim/src/lua/my/checks/init.lua` が全部持っています。各関数は
`{ ok, msg }` のリストを返すだけで、表示にも終了コードにも触りません。

```lua
M.lsp_log_size = function()
  local max_bytes = 5 * 1024 * 1024
  local path = vim.lsp.get_log_path()
  local stat = vim.uv.fs_stat(path)
  local size = stat and stat.size or 0
  return { result(size < max_bytes,
    ("lsp.log is %.1f MB (%s)"):format(size / 1024 / 1024, path)) }
end
```

読み手は 2 種類います。マシンの前にいる自分と、CI。両方に要るからといって
2 回書くと、片方だけ直したときに差が開きます。

## `:checkhealth my` は今そうなっているかを見る

`lua/my/health.lua` は結果を `vim.health.ok` と `.error` に流すだけです。

LSP の attach 検査だけ事情が違います。バッファが開いていないと判定できないので、
開いているバッファを走査して、期待を宣言してある filetype のものだけ見ます。
該当が無ければ info を出して終わり。

```lua
M.expected_lsp_clients = { cs = { "omnisharp" }, lua = { "lua_ls" } }
M.lsp_client_noise = { copilot = true, ["null-ls"] = true, ["GitHub Copilot"] = true }
```

noise 側が要るのは、言語に紐づかないクライアントも同じバッファに attach する
からです。これを除かないと、copilot が居るだけで期待と一致しなくなります。

## CI は状態を作ってから見る

headless 側には開いているバッファがありません。`nvim/tests/cs_single_lsp.lua`
は fixture の `.cs` を開き、omnisharp が attach するまで最大 120 秒待ちます。

そのあと、**もう 5 秒待ちます**。

```lua
vim.wait(5000) -- let any unexpected second server show itself
```

「2 つ目が attach していない」は、その瞬間に見ても確認できません。まだ来て
いないだけかもしれないからです。不在を確かめるには待つ以外にありません。

omnisharp が入っていない環境では SKIP して終わります。ワークフローは
`MasonInstall omnisharp` を明示的に走らせるので、CI で黙って飛ぶことはあり
ません。

## 終了コードと、走らせる側

各プローブは最後に `cq!` か `qa!` を呼びます。`cq!` が非ゼロ終了です。

`nvim/tests/run.sh` が `nvim/tests/*.lua` を順に回します。ここに引っかかり
どころが 2 つ。

- **GNU の `timeout` があるかを調べてから使う。** Windows の
  `System32\timeout.exe` は同名の別物です。`timeout 1 true` が通るかどうかで
  判定しています。
- **パスを native 形式に直す。** Windows の nvim は MSYS 形式の `/d/...` を
  開けないので、`cygpath -m` を通してから渡します。

ubuntu と windows の両方で走らせていて、直近は 2026-07-16 に緑。`nvim/**` が
変わったときだけ動きます。
