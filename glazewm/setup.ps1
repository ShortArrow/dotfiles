#! pwsh
 
# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

$list = @("config.yaml")
foreach ($item in $list) {
  Remove-Item -Force "$env:USERPROFILE/.glzr/glazewm/$item"
  New-Item `
    -Type SymbolicLink `
    -Path "$env:USERPROFILE/.glzr/glazewm/" `
    -Name $item `
    -Value "$scriptDirectory/$item"
}
