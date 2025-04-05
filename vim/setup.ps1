#! pwsh

# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

$fileName1 = ".vimrc"
$fileName2 = ".gvimrc"

Remove-Item -Force $env:USERPROFILE/$fileName1
Remove-Item -Force $env:USERPROFILE/$fileName2

New-Item -Type SymbolicLink `
  -Path $env:USERPROFILE `
  -Name $fileName1 `
  -Value $scriptDirectory/$fileName1

New-Item -Type SymbolicLink `
  -Path $env:USERPROFILE `
  -Name $fileName2 `
  -Value $scriptDirectory/$fileName2

