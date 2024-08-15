$Port = 22

Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

if ($null -eq (Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*')) {
  # Install the OpenSSH Client
  Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

  # Install the OpenSSH Server
  Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
  # Start the sshd service
  Start-Service sshd

  # OPTIONAL but recommended:
  Set-Service -Name sshd -StartupType 'Automatic'

  # Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
  if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
      Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
      New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort $Port
  } else {
      Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
  }
}

ssh-keygen -t ed25519

Start-Service ssh-agent
Start-Service sshd
Set-Service -Name ssh-agent -StartupType Automatic
Set-Service -Name sshd -StartupType Automatic

ssh-add $env:USERPROFILE\.ssh\id_ed25519

$authorizedKey = Get-Content -Path $env:USERPROFILE\.ssh\id_ed25519.pub
Add-Content -Force -Path $env:ProgramData\ssh\administrators_authorized_keys -Value "$authorizedKey"
icacls.exe "$env:ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"

Restart-Service ssh-agent
Restart-Service sshd

New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Program Files\PowerShell\7\pwsh.exe" -PropertyType String -Force

