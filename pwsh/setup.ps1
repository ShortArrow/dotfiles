#!pwsh

# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
echo "Script directory: $scriptDirectory"

# Set the target directory
$targetDirectory = (Split-Path $PROFILE -Parent)
echo "Target directory: $targetDirectory"

if (Test-Path "$targetDirectory/myplug") {
    Remove-Item "$targetDirectory/myplug" -Force
}
New-Item -Type SymbolicLink -Path "$targetDirectory" -Name "myplug" -Value "$scriptDirectory/src"

Get-ChildItem -Path $env:LOCALAPPDATA -Force -ErrorAction 'silentlycontinue' |
Where-Object { $_.Attributes -match "ReparsePoint" -and $_.Name -match "pwsh_myplug" }

Write-Output ". $targetDirectory/myplug/pwsh_myplug.ps1" |
Out-File -FilePath $PROFILE -Encoding utf8 -Force
