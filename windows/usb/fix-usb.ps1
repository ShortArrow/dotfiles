$ErrorActionPreference = 'Stop'

# 1. USB セレクティブサスペンドを無効化 (AC/DC)
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setactive SCHEME_CURRENT
Write-Output 'USBセレクティブサスペンド: AC/DC を無効化'

# 2. USB系デバイスの「電力節約でオフ」を一括無効化 (マウス + 音声含む)
$changed = 0
Get-CimInstance MSPower_DeviceEnable -Namespace root/wmi |
  Where-Object { $_.InstanceName -match 'USB' -and $_.Enable } |
  ForEach-Object {
    Set-CimInstance $_ -Property @{ Enable = $false }
    Write-Output ("省電力オフ無効化: " + $_.InstanceName)
    $changed++
  }
Write-Output ("変更したデバイス数: " + $changed)

# 3. 検証出力
Write-Output '--- 検証: USBサスペンド現在値 ---'
powercfg /query SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 |
  Select-String 'Current AC|Current DC'
Write-Output 'DONE'
