#!pwsh
$Raw = Get-Content -Path "$PSScriptRoot/PATH.txt"
$ConcatedPath = $Raw -join ";"
$PathRegistryLocation = "HKCU:\Environment"

Write-Host -ForegroundColor Yellow "Current PATH environment variable:"
$CurrentPathEntry = Get-ItemProperty -Path $PathRegistryLocation -Name Path
$CurrentPathEntry

Write-Host -ForegroundColor Red "WARNING: This script will overwrite your current PATH environment variable!"

$Response = Read-Host "The following PATH will be applied (y/N)"

if ($Response -eq "y")
{
  $BackupPath = Join-Path $PSScriptRoot "PATH.bk.txt"
  $CurrentPathEntry.Path -split ";" | Set-Content -Path $BackupPath
  Write-Host -ForegroundColor Cyan "Backed up current PATH to $BackupPath"

  Set-ItemProperty -Path $PathRegistryLocation -Name Path -Value $ConcatedPath
  Write-Host -ForegroundColor Green "New PATH environment variable applied:"
} else
{
  Write-Host -ForegroundColor Cyan "Operation cancelled by user. No changes made."
  exit
}

