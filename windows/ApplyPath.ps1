#!pwsh
param(
  [ValidateSet("User", "Machine")]
  [string]$Target = "User"
)

[bool]$IsUser = $Target -eq "User"
[string]$Name = "Path"

[string]$Source = $IsUser ? "$PSScriptRoot/PATH.txt" : "$PSScriptRoot/SYSTEM_PATH.txt"
$Raw = Get-Content -Path $Source
$ConcatedPath = $Raw -join ";"

[string]$UserPath = "HKCU:\Environment"
[string]$SystemPath = "HKLM:\System\CurrentControlSet\Control\Session Manager\Environment"
[string]$PathRegistryLocation = $IsUser ? $UserPath : $SystemPath

Write-Host -ForegroundColor Yellow "Current PATH environment variable:"
$CurrentPathEntry = Get-ItemProperty -Path $PathRegistryLocation -Name $Name
$CurrentPathEntry

Write-Host -ForegroundColor Red "WARNING: This script will overwrite your current PATH environment variable!"

$Response = Read-Host "The following PATH will be applied (y/N)"

function Get-BackupName {
  param (
    [string]$FilePath
  )
  $FullPath = Get-Item -Path $FilePath
  $Directory = $FullPath.DirectoryName
  $BaseName = $FullPath.BaseName
  $Extension = $FullPath.Extension
  $NewPath = Join-Path -Path $Directory -ChildPath ("$BaseName.bk$Extension")
  return $NewPath
}

if ($Response -eq "y") {
  
  $BackupPath = Get-BackupName -FilePath $Source
  $CurrentPathEntry.Path -split ";" | Set-Content -Path $BackupPath
  Write-Host -ForegroundColor Cyan "Backed up current PATH to $BackupPath"

  Set-ItemProperty -Path $PathRegistryLocation -Name $Name -Value $ConcatedPath
  Write-Host -ForegroundColor Green "New PATH environment variable applied:"
}
else {
  Write-Host -ForegroundColor Cyan "Operation cancelled by user. No changes made."
  exit
}

