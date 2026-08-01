---
name: avalonia-screenshot
description: |
  Avalonia アプリのウィンドウを、アプリ本体を起動せずに PNG へ描き出す。RenderTargetBitmap.Render(window) が核で、デザイン時 ViewModel を差し込めば任意の画面状態を再現できる。
  AXAML を直して撮って確認するループを回すための手法。レイアウト完了を待たずに撮ると空や崩れた画像になり、ネイティブハンドルを持つコントロールは画面外で例外を投げる。
  Triggers: Avalonia のスクリーンショット, AXAML の見た目確認, デザインプレビュー, ウィンドウのレイアウト確認
allowed-tools: Bash, Read, Glob, Grep
---

# Avalonia Screenshot

手法の選択は `any-screenshot` が担う。ここは Avalonia 固有の描き出し。

**アプリを起動しない。** ウィンドウを画面外に置いて `Show()` し、`RenderTargetBitmap` に描画して閉じる。実行中のアプリを操作して目的の画面に辿り着く必要がないので、状態の再現が確実で速い。

## 核心

```csharp
var bitmap = new RenderTargetBitmap(new PixelSize(w, h), new Vector(96, 96));
bitmap.Render(window);
using var stream = File.Open(path, FileMode.Create, FileAccess.Write);
bitmap.Save(stream);
```

`Avalonia.Headless` パッケージではなく、**実ウィンドウを画面外に配置する**方式。GPU バックエンドやテーマがそのまま効くので、実際の見た目と一致する。

```csharp
window.WindowStartupLocation = WindowStartupLocation.Manual;
window.Position = new PixelPoint(-2000, -2000);
window.Show();
```

すべて `Dispatcher.UIThread` 上で行う。

## 崩れる 3 つの原因

**レイアウト未完了。** `Show()` 直後に撮ると空か崩れた画像になる。`LayoutUpdated` を待ち、さらに Render 優先度でディスパッチャを一巡させる。

```csharp
await window.WaitForLayoutAsync(TimeSpan.FromSeconds(2));
await Dispatcher.UIThread.InvokeAsync(() => { }, DispatcherPriority.Render);
await Task.Delay(200);
```

`WaitForLayoutAsync` は `LayoutUpdated` を一度だけ拾ってタイムアウト付きで待つ拡張メソッドとして書く。待ち切れなくても撮る（警告を出す）方が、無言で止まるより扱いやすい。

**ネイティブハンドルを持つコントロール。** ビデオ表示など native window を作る要素は画面外描画で失敗する。論理ツリーと視覚ツリーの両方から探して、同寸法の `Border` に差し替える。

```csharp
window.GetLogicalDescendants().OfType<NativeVideoView>()
  .Concat(window.GetVisualDescendants().OfType<NativeVideoView>())
  .Distinct()
```

**ハングするウィンドウ。** 1 枚ごとにタイムアウトを掛け、超えたらスキップして次へ進む。全体が巻き添えで死なないようにする。

## 画面状態の作り分け

デザイン時 ViewModel を `DataContext` に差し込む。同じウィンドウの「記録中 / 停止中」「オンライン / オフライン」などを、アプリを操作せずに撮り分けられる。

**適用の順序が効く。**

| 対象 | タイミング | 理由 |
|---|---|---|
| `DataContext` の差し替え | `Show()` **前** | `INotifyPropertyChanged` 未実装の ViewModel でも反映される |
| タブ選択などの操作 | `Show()` **後** | ビジュアルツリーが構築されていないと要素を辿れない |

タブは `GetVisualDescendants().OfType<TabControl>()` で掴み、ヘッダー文字列で照合して `SelectedIndex` を設定する。

## 組み込み方

撮影専用のコンソールプロジェクトを 1 つ足し、アプリの View と ViewModel を参照させる。ウィンドウ生成をラムダで列挙しておけば、`--only <名前>` で対象を絞れる。

```
src/screenshot/
├── Program.cs           Avalonia の初期化と引数解析
├── ScreenshotRunner.cs  上記の描画・待機・保存
└── ScreenshotTarget.cs  ウィンドウ名 → 生成ラムダ の対応表
```

出力先はリポジトリ内の `docs/screenshots/` にすると、レビューで差分が見える。
