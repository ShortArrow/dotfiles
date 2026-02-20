#!pwsh

# SSH Permission Doctor for Windows
$sshPath = "$env:USERPROFILE\.ssh"

if (-not (Test-Path $sshPath))
{
  Write-Host "[-] .ssh フォルダが見つかりません: $sshPath" -ForegroundColor Red
  exit
}

Write-Host "[*] .ssh フォルダの権限を修復中..." -ForegroundColor Cyan

# 1. フォルダ全体の継承を無効化し、現在の権限をコピー
icacls $sshPath /inheritance:r

# 2. 自分（現在のユーザー）に「このフォルダと配下の全ファイル」へのフルコントロール権限を付与
# (OI): Object Inherit - ファイルに継承
# (CI): Container Inherit - フォルダに継承
icacls $sshPath /grant:r "${env:USERNAME}:(OI)(CI)F"

# 3. 不要なアカウントを徹底的に削除
$removeList = @("SYSTEM", "Administrators", "Everyone", "Users", "Authenticated Users")
foreach ($account in $removeList)
{
  icacls $sshPath /remove $account /c
}

# 4. 個別のファイル（configや秘密鍵）にも設定が適用されているか確認・強制
# これにより、Neovim等がファイルを再作成しても適切な権限が引き継がれるようになります
icacls "$sshPath\*" /inheritance:r
icacls "$sshPath\*" /grant:r "${env:USERNAME}:F"

Write-Host "[+] 修復が完了しました！現在の権限を確認します:" -ForegroundColor Green
icacls $sshPath
icacls "$sshPath\config"
