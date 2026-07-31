---
name: any-screenshot
description: |
  画面を撮る手法の選択ゲート。撮る前にここで分岐する。何を撮るか（Web ページ / Avalonia アプリ / Win32 ウィンドウ / TUI / デスクトップ / SSH・RDP 越し）で正解が変わり、選択を誤ると黒画像や崩れた画像を掴む。
  失敗の多くはエラーを出さない — 撮れたつもりで進んでしまうのを防ぐのが目的。実際の撮影は windows-screenshot / avalonia-screenshot などの個別スキルが担う。
  Triggers: スクリーンショット, screenshot, スクショ, 画面を撮って, UI確認, 見た目確認, デザイン確認, 画面が真っ黒
allowed-tools: Read
---

# Any Screenshot

**撮る前に手法を選ぶ。** 手を動かす前にこの表で分岐し、該当するスキルへ移る。

| 撮りたいもの | 手法 | 移動先 |
|---|---|---|
| Web ページ | Claude in Chrome、無ければ Playwright | MCP ブラウザツール / `page.screenshot()` |
| Avalonia アプリのウィンドウ | 画面外レンダリング | `avalonia-screenshot` |
| Win32 / WPF / WinForms のウィンドウ | PrintWindow（PID 指定） | `windows-screenshot` |
| デスクトップ全体 | GDI キャプチャ | `windows-screenshot` |
| SSH / RDP 越しのデスクトップ | スケジュールタスク経由 | `windows-screenshot` |
| TUI アプリ | **撮らない** | `tui-debug` |

## 貫く原則

**キャプチャの失敗は例外を出さない。** 終了コード 0 で、中身の無い画像が残る。だから撮った後に「本当に中身があるか」を確かめるまでが 1 セットになる。

| 症状 | 原因 |
|---|---|
| 真っ黒 / 単色 | SSH や切断中 RDP で window station が無い。最小化。DWM cloak |
| 空 / 崩れている | レイアウト完了前に描画した（Avalonia 系） |
| 目的と違うものが写る | 画面座標の切り取りで、手前のウィンドウを撮った |

疑わしければ distinct color を数えるのが早い。単色に近ければ失敗している。

## ウィンドウ単位で撮れるならそうする

デスクトップ全体より常に良い。他のウィンドウが被らず、解像度に依存せず、実行間の差分比較が安定する。

Avalonia ならアプリの起動すら不要。Win32 系は `PrintWindow` で隠れたまま撮れる。デスクトップ全体を撮るのは、対象が特定できないときの最後の手段。

## TUI は撮らない

ANSI escape で stdout に描画内容が流れているので、リダイレクトして復元する方が確実で速い。画像にすると OCR が要る。`tui-debug` を使う。

## 未整備

**FlaUI**（Win32 / WPF / WinForms を UI Automation で操作しながら撮る）は、この環境に実装が無いため個別スキルを用意していない。要素単位で撮りたい、あるいは操作してから撮りたい場合に必要になる。`windows-screenshot` の PID 指定はウィンドウ全体までしか撮れない。
