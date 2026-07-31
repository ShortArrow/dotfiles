---
name: any-screenshot
description: |
  画面を撮る手法の選択ゲート。何を撮るか（Web ページ / GUI アプリ / 特定ウィンドウ / 画面全体 / SSH・RDP 越し）で正解の手法が変わり、選択を誤ると黒画像やタイムアウトを掴む。
  SSH セッションや切断中の RDP セッションには対話デスクトップが無く、GDI キャプチャはエラーを出さずに真っ黒な PNG を返す — この沈黙する失敗を避けるのがこのスキルの主目的。
  Triggers: スクリーンショット, screenshot, スクショ, 画面を撮って, UI確認, 見た目確認, 画面が真っ黒, リモートで画面を見たい
allowed-tools: Bash, Read
---

# Any Screenshot

**撮る前に手法を選ぶ。** 手を動かす前にこの表で分岐する。

| 撮りたいもの | 手法 | 入口 |
|---|---|---|
| Web ページ | Claude in Chrome、無ければ Playwright | MCP ブラウザツール / `page.screenshot()` |
| Avalonia アプリのウィンドウ | ヘッドレスレンダリング | アプリを起動せず描画。***REMOVED*** の `***REMOVED***` が実例 |
| Win32 / WPF / WinForms の特定ウィンドウ | FlaUI | UI Automation で要素を掴んでから撮る |
| TUI アプリ | **撮らない** | `tui-debug` を使う |
| 画面全体（対話セッション内） | GDI キャプチャ | `scripts/Save-Screenshot.ps1` |
| 画面全体（SSH / RDP 越し） | スケジュールタスク経由 | `scripts/Invoke-ScreenshotViaTask.ps1` |

## 沈黙する失敗

**SSH セッションと切断中の RDP セッションには window station が無い。** GDI の `CopyFromScreen` はそこで例外を投げず、**真っ黒な PNG を正常終了で返す**。撮れたつもりで進んでしまうのが厄介で、この一点がこのスキルの存在理由。

回避策は、対話ユーザーとして動く一回限りのスケジュールタスクを登録し、その中で撮らせること。呼び出し側はヘッドレスのまま、撮影だけがデスクトップセッションで起きる。

```pwsh
./scripts/Invoke-ScreenshotViaTask.ps1 -Path C:/temp/remote.png
```

対象ユーザーがログオンしてデスクトップを持っていることが前提。完全にサインアウトしたマシンには撮るものが無い。

## 対話セッション内なら直接

```pwsh
./scripts/Save-Screenshot.ps1 -Path C:/temp/before.png
```

全モニタを囲む矩形（virtual screen）を 1 枚に収める。どちらのスクリプトも保存先パスを stdout に出すので、そのまま `Read` に渡せる。

## GUI アプリは画面全体を撮らない

ウィンドウ単位で撮れるなら、そちらが常に良い。他のウィンドウが被らず、解像度に依存せず、差分比較が安定する。

**Avalonia** はヘッドレスでウィンドウを描画できるので、アプリを起動する必要すらない。AXAML を直して撮って確認、というループが速く回る。

**FlaUI** は UI Automation で目的のウィンドウや要素を特定してから撮る。Win32 / WPF / WinForms が対象。アプリの起動は必要。

## TUI は撮らない

ANSI escape で stdout に描画内容が流れているので、リダイレクトして復元する方が確実で速い。画像にすると OCR が要る。`tui-debug` スキルを使う。

## 出典

`scripts/` は [ShortArrow/Get-ScreenShot](https://github.com/ShortArrow/Get-ScreenShot)（private）から取り込んだもの。取り込みにあたって加えた変更:

- 保存先を `-Path` で指定できるようにし、確定したパスを stdout に返す。呼び出し側が撮れたファイルを読めないと自動化にならないため
- 固定 3 秒待ちを、ファイル出現のポーリング（既定 30 秒）に置換。高解像度や低速なデスクトップでは 3 秒後の `Unregister-ScheduledTask` が撮影中のタスクを消し得た
- タスク名に GUID 断片を付与し、多重実行で衝突しないようにした
