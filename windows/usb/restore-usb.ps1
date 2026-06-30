$ErrorActionPreference = 'Stop'

# fix-usb.ps1 の逆操作: USB省電力をWindows既定(有効)に戻す

# 1. USB セレクティブサスペンドを有効化 (AC/DC) ※既定値
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 1
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 1
powercfg /setactive SCHEME_CURRENT
Write-Output 'USBセレクティブサスペンド: AC/DC を有効化(既定)'

# 2. USB系デバイスの「電力節約でオフ」を一括有効化 (Windows既定)
$changed = 0
Get-CimInstance MSPower_DeviceEnable -Namespace root/wmi |
  Where-Object { $_.InstanceName -match 'USB' -and -not $_.Enable } |
  ForEach-Object {
    Set-CimInstance $_ -Property @{ Enable = $true }
    Write-Output ("省電力オフ許可を復元: " + $_.InstanceName)
    $changed++
  }
Write-Output ("変更したデバイス数: " + $changed)

# 3. 検証出力
Write-Output '--- 検証: USBサスペンド現在値 ---'
powercfg /query SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 |
  Select-String 'Current AC|Current DC'
Write-Output 'DONE'
