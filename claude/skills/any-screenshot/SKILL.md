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
| 実行中アプリのウィンドウ全体 | PrintWindow（PID 指定） | `windows-screenshot` |
| 実行中アプリの要素単位 / 操作してから撮る | UI Automation | `flaui-screenshot` |
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

## PrintWindow と UI Automation の使い分け

どちらも実行中アプリを撮るが、性質が逆。

| | `windows-screenshot` | `flaui-screenshot` |
|---|---|---|
| 方式 | ウィンドウ自身に描画させる | 画面領域をコピーする |
| 隠れたウィンドウ | 撮れる | 撮れない（前面化が必要） |
| 粒度 | ウィンドウ全体 | 要素単位 |
| 操作してから撮る | できない | できる |
| 対象の準備 | 不要 | AutomationId が要る |

隠したまま撮りたいだけなら前者。押してから撮る、あるいはボタン 1 個を切り出すなら後者。

## Web

Claude in Chrome が使えるならそれが最短。使えない環境では Playwright の `page.screenshot()`。どちらも個別スキルは用意していない — 分岐がここで完結し、手法固有の落とし穴が少ないため。
