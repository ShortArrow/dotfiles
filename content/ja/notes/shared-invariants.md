---
title: ":checkhealth と CI で同じ検査を使う"
description: "設定が正しくても Neovim が固まることがあります。原因が余分な言語サーバー、巨大なログファイル、早すぎるプラグインの読み込みといった、マシン側の状態にあるからです。これらを見つける検査は 1 つのモジュールにまとめ、:checkhealth からも headless の CI からも同じものを実行しています。その構成と、「無いこと」を確かめるには待つしかない理由を書きます。"
summary: "`:checkhealth my` と headless CI が同じ検査を使う理由と、不在を確かめるのに待ち時間が要る理由。"
---

このマシンでは、リポジトリの設定が正しいのに Neovim が固まることがあります。
どの場合も、原因は設定の外側にあるマシンの状態でした:

- mason に C# の言語サーバーが 3 つ入っていた。omnisharp、omnisharp-mono、
  csharp-language-server です。3 つとも `.cs` のバッファに attach するので、
  ソリューションの読み込みが 3 回走り、最初のシンタックスハイライトが出るまで
  UI スレッドが止まります。設定が要求しているサーバーは 1 つで、残りの 2 つは
  インストールされていただけです。
- `lsp.log` が数 MB に育っていた。どこかのサーバーが WARN の行を出し続けて
  いて、その 1 行ずつが編集中に同期的に書き込まれます。
- blink.cmp が `InsertEnter` より前に読み込まれていた。require には
  [このマシン](/ja/machine/)で 1 秒ほどかかり、その 1 秒をファイルを開くたびに
  払っていました。

どれも lint では見つかりません。リポジトリのファイルは正しく、変わったのは
それが動く環境の側だからです。

## 検査は 1 つのモジュールに置く

`nvim/src/lua/my/checks/init.lua` にすべての検査があります。各関数は
`{ ok, msg }` のリストを返すだけで、それ以外のことはしません。画面に出力
せず、終了コードも設定しません。

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

同じ検査が、エディタの中での対話的な確認と CI の 2 か所で必要です。2 回書くと、
片方だけ直して、もう片方が古い答えを返し続けることになります。

## `:checkhealth my` は今の状態を報告する

`lua/my/health.lua` は各検査を実行し、結果を `vim.health.ok` か
`vim.health.error` に渡します。

attach している LSP クライアントの検査だけは作りが違います。報告するには
開いているバッファが必要だからです。この検査は読み込まれているバッファを
順に見て、期待値を宣言してある filetype のものだけを対象にし、該当する
バッファがなければその旨を出します。

```lua
M.expected_lsp_clients = { cs = { "omnisharp" }, lua = { "lua_ls" } }
M.lsp_client_noise = { copilot = true, ["null-ls"] = true, ["GitHub Copilot"] = true }
```

noise の一覧があるのは、copilot のように言語に紐づかないクライアントも同じ
バッファに attach するからです。この一覧がないと、copilot が動いているだけで
比較が失敗します。

## CI は状態を作ってから検査する

headless の Neovim には開いているバッファがないので、CI のプローブは状況を
自分で作ります。`nvim/tests/cs_single_lsp.lua` は fixture の `.cs` ファイルを
開き、omnisharp が attach するまで最大 120 秒待ちます。

そのあと、さらに 5 秒待ちます:

```lua
vim.wait(5000) -- let any unexpected second server show itself
```

確かめたいのは「2 つ目のサーバーが attach しない」ことです。これはある瞬間を
見ただけでは確認できません。2 つ目がまだ起動していないだけかもしれないから
です。何かが無いことを確かめるには、それが現れるのに十分な時間を待つしか
ありません。

omnisharp が入っていない環境では、このプローブは自分をスキップします。CI で
このスキップが検査を隠してしまわないように、ワークフローはプローブの前に
`MasonInstall omnisharp` を明示的に実行しています。

## 終了コードと実行側

各プローブは最後に `cq!` か `qa!` を呼びます。非ゼロで終了するのは `cq!` です。

`nvim/tests/run.sh` が `nvim/tests/*.lua` を順に実行します。Windows で動かす
ために 2 つの配慮があります:

- GNU の `timeout` があるかを確かめてから使います。Windows の `System32` には
  同じ名前の無関係なプログラムがあるので、`timeout 1 true` が成功するかで
  判定しています。
- Neovim にはネイティブ形式のパスを渡します。Windows の Neovim は `/d/...` の
  ような MSYS 形式のパスを開けないので、各テストファイルを `cygpath -m` で
  変換してから渡します。

ワークフローは ubuntu と windows でプローブを実行し、動くのは `nvim/**` に
変更があったときだけです。
