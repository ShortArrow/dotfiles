#! pwsh

# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

$Roaming = "$env:USERPROFILE/Appdata/Roaming/"
$zedConfig = Join-Path $Roaming "Zed"

if(Test-Path $zedConfig) {
  Remove-Item -Recurse -Force $zedConfig
}
New-Item -Type SymbolicLink `
  -Path $Roaming `
  -Name Zed `
  -Value "$scriptDirectory/src"

