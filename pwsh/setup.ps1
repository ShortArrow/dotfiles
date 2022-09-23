$ProfileDir=(Split-Path $PROFILE -Parent)
if (Test-Path "$ProfileDir/pwsh_myplug.ps1"){
  Remove-Item "$ProfileDir/pwsh_myplug.ps1" -Force
}
New-Item -Type SymbolicLink -Path "$ProfileDir" -Name "pwsh_myplug.ps1" -Value "$env:USERPROFILE/Documents/GitHub/dotfiles/pwsh/pwsh_myplug.ps1"
Get-ChildItem -Path $env:LOCALAPPDATA -Force -ErrorAction 'silentlycontinue' |
Where-Object { $_.Attributes -match "ReparsePoint" -and $_.Name -match "pwsh_myplug"}
echo "Write '. `"`$(Split-Path -Parent `$PROFILE)/pwsh_myplug.ps1`"' in `$PROFILE"
