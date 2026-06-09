---
name: tui-debug
description: AI エージェントから直接 GUI を見れない状況で TUI (ratatui / textual / curses / blessed 等) アプリの表示内容を確認する手法。 stdout/stderr を file にリダイレクトしてキャプチャ → ANSI escape を strip して plain text として読む。 ratatui の動作確認・回帰検証・ユーザに代わってのスモークテスト等に使う。
---

# TUI Debug

AI エージェントは Windows の console window や Linux の TTY を直接 screenshot できない。 一方、 TUI アプリは ANSI escape 経由で stdout に「カーソル位置 + 描画文字列 + 色」を書き出してるので、 **stdout をファイルに redirect すれば描画内容を後で復元できる**。

このスキルは ratatui (Rust) / textual (Python) / curses 等の TUI アプリを起動して画面状態を AI が読み取れる形にする手法をまとめたもの。

## いつ使うか

- ユーザに代わって TUI アプリの起動確認・スモークテストをしたい
- TUI のレイアウト / 色 / 値表示が期待通りか自動的にチェックしたい
- TUI のリリース前回帰検証 (前バージョンとの差分確認)
- バグ報告から実機状態を再現して内部状態を見たい

## 使わない方が良いケース

- 真のインタラクティブ操作 (キー入力に応じた状態遷移の連続検証) ─ stdin 入力も必要になるので別アプローチ (expect / pty 自動化) が向く
- TUI が screen buffer に対して直接書き込む実装 (curses で `addstr` + `refresh` を使うタイプ) で stdout redirect だと描画されないケース。 ほとんどの ratatui / textual / Charm bracelet 等のフレームワークは stdout に書くので大丈夫だが、 一部 native 実装は raw tty 必須
- 全画面 fullscreen 描画 + マウスイベント前提のアプリ

## 基本手順 (PowerShell)

```powershell
# 1. アプリを起動、 stdout/stderr を file に redirect、 window は hidden で
Push-Location <project>
$proc = Start-Process -FilePath <tui_app.exe> `
    -ArgumentList <args> `
    -RedirectStandardOutput "$env:TEMP\tui_out.log" `
    -RedirectStandardError  "$env:TEMP\tui_err.log" `
    -PassThru -WindowStyle Hidden
Pop-Location

# 2. TUI が描画完了するまで待つ (アプリによる、 通常 2〜5 秒)
Start-Sleep -Seconds 4
Write-Host "[viewer] pid=$($proc.Id) HasExited=$($proc.HasExited)"

# 3. stdout を読み、 ANSI escape を strip して plain text として表示
$raw = Get-Content "$env:TEMP\tui_out.log" -Raw
# 主要 ANSI escape 形式:
#   `e[<n>;<m>H        : カーソル位置移動 (n=row, m=col)
#   `e[<params>m       : SGR (色/style)
#   `e[?<n>h or `e[?<n>l : DECSET (モード切替、 alternate screen 等)
$clean = $raw -replace "`e\[[0-9;]*[a-zA-Z]", ""
$clean = $clean -replace "`e\[\?[0-9]+[a-zA-Z]", ""
$clean -split "`n" | Select-Object -Last 60

# 4. 終了 (cleanup)
Stop-Process -Id $proc.Id -Force
```

`-WindowStyle Hidden` を付けることでユーザの操作中に勝手にコンソールが出現するのを防げる。 ただし TUI によっては hidden だと描画 thread が起動しないものもあるので、 もし stdout が空なら `-NoNewWindow` や `-WindowStyle Normal` を試す。

## 手順 (bash / Linux / WSL)

```bash
# 1. 起動 + redirect
nohup <tui_app> <args> > /tmp/tui_out.log 2> /tmp/tui_err.log < /dev/null &
PID=$!

# 2. wait
sleep 4

# 3. strip ANSI 経由で読む
sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g; s/\x1b\[\?[0-9]+[a-zA-Z]//g' /tmp/tui_out.log | tail -60

# 4. cleanup
kill $PID
```

## ANSI escape strip 正規表現の補足

主要パターン:

| 形式 | 例 | 用途 | strip 用 regex (PCRE) |
|---|---|---|---|
| CSI + SGR | `\e[38;5;3;49m` | 色 (256-color 等) | `\e\[[0-9;]*m` |
| CSI + cursor | `\e[5;10H` | カーソル位置 | `\e\[[0-9;]*H` |
| CSI + clear | `\e[2J` | 画面クリア | `\e\[[0-9;]*J` |
| DECSET | `\e[?1049h` | alternate screen | `\e\[\?[0-9]+[a-zA-Z]` |
| OSC | `\e]0;title\a` | ウィンドウタイトル | `\e\][0-9;]*[a-zA-Z]*\a` |

汎用 fallback (大半のケースをまとめてカバー):

```regex
\e\[[0-9;?]*[a-zA-Z]
```

または ANSI 全部消したい場合:

```regex
\x1b(\[[0-9;?]*[a-zA-Z]|\][0-9;]*\x07)
```

## 注意事項

### 1. キャプチャされる内容はカーソル位置と差分更新の連続

TUI は full-refresh するアプリ (1 frame = 全画面再描画) と差分更新するアプリ (`\e[H` でカーソル戻して上書き、 もしくは `\e[r;cH` でピンポイント更新) がある。 後者だと **後ろに行くほど現在の画面に近づく**。 `tail -60` 程度で「最後の表示状態」を見ると良い。

### 2. ratatui 等は alternate screen buffer を使う

ratatui は起動時に `\e[?1049h` で alternate screen に入り、 終了時 `\e[?1049l` で戻す。 redirect captured では両方が現れるので、 終了後にキャプチャ読むと描画内容が消えてるように見えるケースもある。 **プロセス生存中に読む** のが基本。

### 3. wide char / マルチバイト文字

日本語等の wide char (2 セル幅) があると、 列カウントがズレる。 strip 後の plain text で読む分には問題ないが、 grid アライメントは崩れて見える。 値の検証はそれを承知で。

### 4. process が即死してないか確認

`HasExited` でチェック。 即死してれば config エラー等が `stderr` に出てるはず。 必ず `*_err.log` も覗く:

```powershell
Get-Content "$env:TEMP\tui_err.log" | Select-Object -Last 30
```

### 5. tracing / log 系の出力は分離する

アプリが `tracing` や `log` クレートで warn/info を吐く場合、 stdout じゃなく stderr に出るのが普通。 上の redirect 両方やってれば両方拾える。 が、 TUI 描画と混ざってると ANSI strip 後にログ行も残るので、 必要に応じて prefix で grep する。

## ratatui アプリの典型的なキャプチャ結果例

```
┌Tabs───────────────────────────────────────────────────┐
│ Tab A │ Tab B │ All │
└─────────────────────────────────────────────────────────┘
┌ stream_out [SEND] ─────────────────┐┌ stream_in [RECV] fr:21 [0/41] ───┐
│ Waiting for data...                ││ Row Name       B  HEX   Value    │
│                                    ││  1  field_0    1  7E    126      │
│                                    ││  2  field_1    2  01 00 1        │
│                                    ││  3  field_2    2  3C 00 60       │
...
```

罫線が崩れて見えても、 各行の Name / HEX / Value はテキスト的に抽出可能。 これで「frame は流れてるか」「特定 field の値が想定範囲か」を AI が判定できる。

## 関連スキル / 補完

- 完全自動化 (キー操作含む) → expect / pty 自動化 (このスキルは扱わない)
- screenshot 取得 (GUI app) → Windows なら `System.Drawing.Bitmap.CopyFromScreen`、 Linux なら ImageMagick `import`
- TUI 内部 state を直接抜く → IPC 経由 (アプリに JSON dump endpoint を仕込む等)、 そっちが楽な場合も多い
