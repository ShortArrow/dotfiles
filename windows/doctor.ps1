function Test-CommandExist([string]$cmd)
{
  $foundCommand = Get-Command $cmd -ErrorAction SilentlyContinue
  $exists = $null -ne $foundCommand -and $foundCommand.Count -gt 0
  return $exists
}
function Show-Result()
{
  param (
    [bool]$IsOK
  )
  Write-Host "- [" -NoNewline
  Write-Host $($IsOK ? "OK" : "NG") -ForegroundColor $($IsOK ? "Green" : "Red") -NoNewline
  Write-Host "]: " -NoNewline
}
function Show-BooleanResult()
{
  param (
    [bool]$ExpectedValue,
    [bool]$ActualValue
  )
  Show-Result -IsOK ($ExpectedValue -eq $ActualValue)
}
function Show-CheckResult()
{
  param (
    [string]$TargetName,
    [string]$ExpectedValue,
    [string]$ActualValue
  )
  Show-Result -IsOK ($ExpectedValue -eq $ActualValue)
  Write-Host "$ActualValue" -NoNewline
  if (-not $IsOK)
  {
    Write-Host ", Expected: $ExpectedValue" -ForegroundColor Yellow -NoNewline
  }
  Write-Host ", ($TargetName)" -ForegroundColor DarkGray
}

function Test-ItemPropertyValue()
{
  param (
    [string]$TargetPath,
    [string]$TargetName,
    [string]$ExpectedValue
  )
  $ActualValue = Get-ItemPropertyValue -Path "$TargetPath" -Name $TargetName
  Show-CheckResult  -TargetName "$TargetPath\$TargetName" -ExpectedValue $ExpectedValue -ActualValue $ActualValue
}

function Test-Command()
{
  param (
    [string]$CommandName
  )
  $IsExists = Test-CommandExist $CommandName
  $CommandPath = $IsExists ? $(Get-Command $CommandName).Path : "#N/A"
  Show-Result -IsOK $IsExists
  Write-Host "$CommandName" -NoNewline
  Write-Host ", $CommandPath" -ForegroundColor DarkGray
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

# Check Command
$Commands = @(
  # Node.js
  "volta",
  "node",
  "npm",
  "pnpm",
  "yarn",
  "npx",
  # Rust
  "cargo",
  "rustup",
  "rust-analyzer",
  # Python
  "uv",
  "python",
  "python3",
  "pip",
  "pip3",
  "ruff",
  # Go
  "go",
  # TUI
  "lazygit",
  "lazydocker",
  "rg",
  "fzf",
  "fd",
  # Terminal
  "wt",
  "wezterm",
  "alacritty",
  # Editor
  "nvim",
  "vim",
  "code",
  "code-insiders",
  "zed",
  # C
  "cmake",
  "make",
  "hmake",
  "clangd",
  "clang++",
  "g++",
  "zig",
  "nim",
  # Dotnet
  "dotnet",
  # Elm
  "elm",
  # UI
  "glazewm",
  # Basic
  "qemu"
  "ssh"
  "7z",
  "git"
)
foreach ($Command in $Commands)
{
  Test-Command -CommandName $Command
}

