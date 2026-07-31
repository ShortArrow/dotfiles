---
name: flaui-screenshot
description: |
  実行中の Win32 / WPF / Avalonia デスクトップアプリを FlaUI (UI Automation) で掴み、ウィンドウや要素単位でキャプチャする。撮った Bitmap のピクセルを直接検査すれば、描画されているかを自動テストで判定できる。
  Capture.Element は画面領域コピーなので SetForeground() で前面に出さないと隠れたウィンドウを撮れない。要素の同定は AutomationId が基準で、Avalonia の x:Name は UIA に出ない。
  Triggers: FlaUI, UI Automation, 要素のスクリーンショット, UIテストで画面を撮る, 描画されているか検証したい
allowed-tools: Bash, Read, Glob, Grep
---

# FlaUI Screenshot

手法の選択は `any-screenshot` が担う。ここは UI Automation でアプリを掴んでから撮る経路。

**要素単位で撮れるのが他手法との差**。ウィンドウ全体しか撮れない `windows-screenshot` と違い、ボタン 1 個やパネル 1 枚を切り出せる。アプリを操作してから撮ることもできる。

## 撮る

```csharp
window.SetForeground();
using var capture = Capture.Element(window);
Bitmap bitmap = capture.Bitmap;
```

`Capture.Element` は **UIA で得た矩形を画面からコピーする**方式。`windows-screenshot` の `PrintWindow` と違い、**隠れているウィンドウは撮れない**。`SetForeground()` が必須で、実際に前へ出たかまで確認する。

```csharp
window.SetForeground();
WaitUntil(() => window.Properties.IsOffscreen.ValueOrDefault == false, TimeSpan.FromSeconds(2));
```

サブウィンドウを開くとそれが最前面を奪うので、親ウィンドウを撮る前には毎回戻す必要がある。

## 撮った画像を検証に使う

`capture.Bitmap` は `System.Drawing.Bitmap` なので、そのままピクセルを読める。「描画されているか」を人間の目に頼らず判定できる。

```csharp
// ビデオ領域だけを間引き走査し、青系ピクセルの有無で描画を判定する。
// 走査範囲を絞るのは、ウィンドウ枠やステータス表のテーマ色を拾わないため。
for (int y = top; y < bottom; y += 8)
    for (int x = left; x < right; x += 8)
    {
        Color pixel = bitmap.GetPixel(x, y);
        if (pixel.B > pixel.R + 40 && pixel.B > pixel.G + 30) return true;
    }
```

**走査範囲を絞るのが要点。** ウィンドウ全体を見ると、枠やアクセントカラーが期待色と一致して偽陽性になる。

## アプリを掴む

```csharp
var automation = new UIA3Automation();
var process = Process.Start(psi);
var app = Application.Attach(process.Id);
```

`Application.Launch` ではなく `Process.Start` してから `Attach` すると、起動時の環境や作業ディレクトリを制御しやすい。

**ウィンドウの同定は `AutomationId` で行う。** タイトルは重複する（スプラッシュがアプリ名だけを出すなど）ため同定キーにならない。

```csharp
foreach (var window in app.GetAllTopLevelWindows(automation))
{
    string? id;
    try { id = window.AutomationId; } catch { continue; }   // ← 必須
    if (id == "MainWindowRoot") return window;
}
```

**`AutomationId` の読み取りは例外を投げることがある。** 一部のトップレベルウィンドウ（スプラッシュ、プログラム生成ダイアログ）はこのプロパティを提供せず、ガードせずに列挙すると落ちる。

ウィンドウ自身を同定できない場合は、内部の既知要素から辿る。

```csharp
window.FindFirstDescendant(cf => cf.ByAutomationId(childId)) is not null
```

## 要素を探す

```csharp
window.FindFirstDescendant(cf => cf.ByAutomationId("HomeButton"))?.AsButton();
window.FindFirstDescendant(cf => cf.ByName("接続"))?.AsButton();
```

**Avalonia の `x:Name` は UIA の Name に出ない。** `AutomationId` が振られていない要素は、表示テキスト（Content）が最も安定した検索キーになる。逆に言えば、撮りたい要素には `AutomationId` を付けておくのが先。

見つからないときは列挙して確かめる。

```csharp
foreach (var element in window.FindAllDescendants())
    entries.Add($"{element.ControlType}/{element.AutomationId}/'{element.Name}'");
```

`ControlType` / `AutomationId` / `Name` はいずれも読み取りで例外を投げ得るので、個別に try で包む。

## 参照実装

- `V:\***REMOVED***\tests\UI.Tests` — `AppFixture.cs`（起動・同定・前面化）、`***REMOVED***.cs`（キャプチャとピクセル判定）
- `V:\***REMOVED***\tests\UI.Tests` — 同系統の構成
- `V:\***REMOVED***\docs\tests\ui-tests.md`

## Avalonia なら先に検討すること

対象が Avalonia でアプリの起動が不要なら、`avalonia-screenshot` の画面外レンダリングの方が速く確実。前面化も要らず、デスクトップの状態を乱さない。FlaUI が要るのは、**実際に動いているアプリを操作した結果**を撮りたい場合。
