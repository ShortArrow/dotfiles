---
name: windows-screenshot
description: |
  Windows のデスクトップ・ウィンドウを PowerShell で撮る。PID 指定のウィンドウ単体、画面全体、SSH / RDP 越しの 3 経路。
  SSH セッションと切断中の RDP セッションには window station が無く、GDI キャプチャはエラーを出さずに真っ黒な PNG を返す。最小化と DWM cloak も同様に無内容な画像になるため、既定で拒否する。
  Triggers: Windows のスクリーンショット, デスクトップを撮って, PIDのウィンドウを撮って, リモートで画面を見たい, 画面が真っ黒
allowed-tools: Bash, Read
---

# Windows Screenshot

手法の選択は `any-screenshot` が担う。ここは Windows ネイティブの撮影そのもの。

| 用途 | スクリプト |
|---|---|
| PID 指定でウィンドウを撮る | `scripts/Save-WindowScreenshot.ps1` |
| 画面全体（対話セッション内） | `scripts/Save-Screenshot.ps1` |
| 画面全体（SSH / RDP 越し） | `scripts/Invoke-ScreenshotViaTask.ps1` |

どれも保存先パスを stdout に返すので、そのまま `Read` に渡せる。

## PID 指定が既定の選択

```pwsh
./scripts/Save-WindowScreenshot.ps1 -ProcessId 11268 -List
./scripts/Save-WindowScreenshot.ps1 -ProcessId 11268 -TitleMatch 'dotfiles' -Path C:/temp/w.png
```

`PrintWindow` に `PW_RENDERFULLCONTENT` を渡してウィンドウ自身に描画させる。画面座標を切り取る方式に対する利点:

- **隠れていても撮れる。** 前面に出す操作が要らず、デスクトップの状態を乱さない
- **GPU 合成ウィンドウでも黒くならない。** 素の `BitBlt` はここで失敗する
- **解像度に依存しない。** ウィンドウサイズで出るので実行間の差分比較が安定する

1 プロセスが複数ウィンドウを持つ場合（wezterm など）は全て列挙する。`-List` で確認して `-TitleMatch` で絞る。

矩形は `GetWindowRect` ではなく `DWMWA_EXTENDED_FRAME_BOUNDS` から取る。Windows 10 以降の `GetWindowRect` は不可視のリサイズ境界を含むため、そのままでは全キャプチャに透明な余白が付く。

## 無内容になる 3 状態

**いずれもエラーを出さない。** これがこのスキルの主題。

| 状態 | 何が起きるか | 対処 |
|---|---|---|
| SSH / 切断中 RDP | window station が無く、`CopyFromScreen` が終了コード 0 で真っ黒な PNG を返す | `Invoke-ScreenshotViaTask.ps1` |
| 最小化 | 描画すべきサーフェスが無い | 既定で拒否。`-IncludeEmpty` で上書き |
| DWM cloak | シェルが隠している生存ウィンドウ。サスペンド中の UWP、タイリング WM が非表示ワークスペースに置いたもの | 同上 |

cloak が最も紛らわしい。ウィンドウは列挙に出て正しいサイズも返すのに、撮ると単色になる。実測で cloak されたウィンドウを強制撮影したところ distinct color は 1 だった。

## SSH / RDP 越し

```pwsh
./scripts/Invoke-ScreenshotViaTask.ps1 -Path C:/temp/remote.png
```

対話ユーザーとして動く一回限りのスケジュールタスクを登録し、撮影だけをデスクトップセッションで起こす。呼び出し側はヘッドレスのまま。撮影後にタスクは削除される。

対象ユーザーがログオンしてデスクトップを持っていることが前提。サインアウト済みのマシンには撮るものが無い。

## 出典

`scripts/` は作者の非公開リポジトリ `Get-ScreenShot` 由来。取り込み時の変更:

- 保存先を `-Path` で受け、確定パスを stdout に返す。呼び出し側がファイルを読めないと自動化にならない
- 固定 3 秒待ちをファイル出現のポーリング（既定 30 秒）に置換。3 秒後の `Unregister-ScheduledTask` が撮影中のタスクを消し得た
- タスク名に GUID 断片を付与し、多重実行の衝突を防止
- `Save-WindowScreenshot.ps1` は新規
