# windows/usb

USB の省電力設定をまとめてトグルするスクリプト。2.4GHz 無線マウスの
ランダム切断と USB オーディオの不調を解消するために用意した。

## 背景 / 原因

2026 年 6 月下旬から、2.4GHz 無線マウス (`VID_056E&PID_0183`) が操作中でも
ランダムに切断され、USB オーディオデバイスも不調になる症状が発生した。

調査の結果、以下が判明した。

- OS 側に USB 着脱イベント (Kernel-PnP 410/411 等) が**一切記録されていない**
  → ハードの抜き差しではなく、無線リンク断 / 電源管理レベルの問題。
- `2026-06-22` に Windows Update **KB5094126** が適用され、その時刻
  (12:37) に USB/HID ドライバスタック (`usbxhci` / `usbhub3` / `usb.inf` /
  `input.inf` / `hidusb` 系) が**まとめて差し替わっていた**。
- 物理配置・接続機器は 2 年間変更しておらず、発症時期は Update と一致。

新しい USB ドライバ下で USB セレクティブサスペンドおよびデバイス個別の
「電力節約のためにオフにできる」設定が悪さをしていた。これらを無効化する
ことで切断は解消した（実機で確認済み）。

## スクリプト

| ファイル | 内容 |
| --- | --- |
| `fix-usb.ps1` | USB セレクティブサスペンド (AC/DC) を無効化し、全 USB デバイスの「電力節約でオフ」フラグをクリアする |
| `restore-usb.ps1` | 上記を Windows 既定（有効）に戻す |

## 使い方

どちらも管理者権限が必要。`sudo` (Sudo for Windows) 経由で実行する。

```pwsh
# 適用（省電力を無効化して切断を止める）
sudo pwsh -NoProfile -ExecutionPolicy Bypass -File V:\dotfiles\windows\usb\fix-usb.ps1

# 元に戻す（Windows 既定へ）
sudo pwsh -NoProfile -ExecutionPolicy Bypass -File V:\dotfiles\windows\usb\restore-usb.ps1
```

## 補足

- `fix-usb.ps1` は `Enable=$true` のデバイスのみ、`restore-usb.ps1` は
  `Enable=$false` のデバイスのみを対象にするため、繰り返し実行しても安全。
- これは対症療法。恒久対応としては、ベンダー提供の新ドライバ、または
  後続の Windows Update での修正が望ましい。
- 設定は即時反映されるが、確実を期すならデバイスの挿し直しか再起動を行う。
