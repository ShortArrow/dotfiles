$ProfileDir = (Split-Path $PROFILE -Parent)

if (Test-Path "$ProfileDir/myplug") {
  Remove-Item "$ProfileDir/myplug" -Force
}
New-Item -Type SymbolicLink -Path "$ProfileDir" -Name "myplug" -Value "$env:USERPROFILE/Documents/GitHub/dotfiles/pwsh/src"

Get-ChildItem -Path $env:LOCALAPPDATA -Force -ErrorAction 'silentlycontinue' |
Where-Object { $_.Attributes -match "ReparsePoint" -and $_.Name -match "pwsh_myplug" }

Write-Output ". $(Split-Path $PROFILE -Parent)/myplug/pwsh_myplug.ps1" |
Out-File -FilePath $PROFILE -Encoding utf8 -Force
