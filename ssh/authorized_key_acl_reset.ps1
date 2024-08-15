Start-Service ssh-agent
Start-Service sshd
Set-Service -Name ssh-agent -StartupType Automatic
Set-Service -Name sshd -StartupType Automatic

$authorizedKeyContainerFile = "$env:ProgramData\ssh\administrators_authorized_keys"
icacls.exe $authorizedKeyContainerFile /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"

Restart-Service ssh-agent
Restart-Service sshd

$pwshPath = (Get-Command pwsh).Source
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "`"${pwshPath}"`" -PropertyType String -Force

