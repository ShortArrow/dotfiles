$Port = 22

$AreadyInstalled = $null
try {
  $AreadyInstalled = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
}
catch {
  Write-Output "ssh-agent service is already running"
}
if ($null -ne $AreadyInstalled) {
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
    New-NetFirewallRule `
      -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' `
      -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort $Port
  }
  else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
  }
}

$sshPrivateKeyPath = "$env:USERPROFILE\.ssh\id_ed25519"
$sshPublicKeyPath = "$env:USERPROFILE\.ssh\id_ed25519.pub"

if (!(Test-Path $sshPrivateKeyPath) || !(Test-Path $sshPublicKeyPath)) {
  ssh-keygen -t ed25519
}

sudo Start-Service ssh-agent
sudo Start-Service sshd
sudo Set-Service -Name ssh-agent -StartupType Automatic
sudo Set-Service -Name sshd -StartupType Automatic

ssh-add $sshPrivateKeyPath

$authorizedKeyContainerFile = "$env:ProgramData\ssh\administrators_authorized_keys"

$authorizedKey = Get-Content -Path $sshPublicKeyPath
Add-Content -Force -Path $authorizedKeyContainerFile -Value "$authorizedKey"
icacls.exe $authorizedKeyContainerFile /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"

sudo Restart-Service ssh-agent
sudo Restart-Service sshd

$pwshPath = (Get-Command pwsh).Source
sudo New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "`"${pwshPath}"`" -PropertyType String -Force
