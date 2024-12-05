#! pwsh

$item = ".wezterm.lua"

if(Test-Path "$env:USERPROFILE/$item")
{
    Remove-Item "$env:USERPROFILE/$item" -Force
}

New-Item -Type SymbolicLink -Path "$env:USERPROFILE/" -Name $item -Value "$PSScriptRoot/$item"

