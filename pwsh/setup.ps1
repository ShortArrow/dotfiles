$ProfileDir=(Split-Path $PROFILE -Parent)
Remove-Item (Resolve-Path $ProfileDir/pwsh_myplug.ps1) -Force
New-Item -Type SymbolicLink -Path "$ProfileDir" -Name "pwsh_myplug.ps1" -Value "$env:USERPROFILE/Documents/GitHub/dotfiles/pwsh_myplug.ps1"
Get-ChildItem -Path $env:LOCALAPPDATA -Force -ErrorAction 'silentlycontinue' |
Where-Object { $_.Attributes -match "ReparsePoint" -and $_.Name -match "nvim"}
