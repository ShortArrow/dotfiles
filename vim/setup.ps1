#! pwsh

# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

Remove-Item -Force $env:USERPROFILE/.vimrc

New-Item -Type SymbolicLink `
  -Path $env:USERPROFILE `
  -Name ".vimrc" `
  -Value "$scriptDirectory/.vimrc"
