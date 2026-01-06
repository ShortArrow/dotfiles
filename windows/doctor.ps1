function Show-CheckResult()
{
  param (
    [string]$TargetPath,
    [string]$TargetName,
    [string]$ExpectedValue,
    [string]$ActualValue
  )
  Write-Host "- [" -NoNewline
  $IsOK = $ExpectedValue -eq $ActualValue
  Write-Host $($IsOK ? "OK" : "NG") -ForegroundColor $($IsOK ? "Green" : "Red") -NoNewline
  Write-Host "]: " -NoNewline
  Write-Host "$ActualValue" -NoNewline
  if (-not $IsOK)
  {
    Write-Host ", Expected: $ExpectedValue" -ForegroundColor Yellow -NoNewline
  }
  Write-Host ", ($TargetPath\$TargetName)" -ForegroundColor DarkGray
}

function Test-ItemPropertyValue()
{
  param (
    [string]$TargetPath,
    [string]$TargetName,
    [string]$ExpectedValue
  )
  $ActualValue = Get-ItemPropertyValue -Path "$TargetPath" -Name $TargetName
  Show-CheckResult -TargetPath $TargetPath -TargetName $TargetName -ExpectedValue $ExpectedValue -ActualValue $ActualValue
}

# Only Show
$UserEnvPath = "HKCU:\Environment"
Write-Host "User Environment Variables:" -ForegroundColor Cyan
Get-ItemPropertyValue -Path $UserEnvPath -Name Path
$SystemEnvPath = "HKLM:\System\CurrentControlSet\Control\Session Manager\Environment"
Write-Host "System Environment Variables:" -ForegroundColor Cyan
Get-ItemPropertyValue -Path $SystemEnvPath -Name Path

# Check diff
Write-Host "Checking Windows Environment Variables..." -ForegroundColor Cyan
$FileSystemPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
Test-ItemPropertyValue -TargetPath $FileSystemPath -TargetName "LongPathsEnabled" -ExpectedValue "1"
$CodePagePath = "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage"
Test-ItemPropertyValue -TargetPath $CodePagePath -TargetName "ACP" -ExpectedValue "65001"
Test-ItemPropertyValue -TargetPath $CodePagePath -TargetName "OEMCP" -ExpectedValue "65001"
Test-ItemPropertyValue -TargetPath $CodePagePath -TargetName "MACCP" -ExpectedValue "65001"

