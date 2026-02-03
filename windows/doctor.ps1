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

$HilightPattern = @(
  "$env:USERPROFILE",
  "$env:APPDATA",
  "$env:LOCALAPPDATA",
  "$env:PROGRAMFILES",
  "$env:PROGRAMFILES(X86)",
  "$env:SYSTEMROOT"
)

function Get-PrefixMatchIndices
{
  [OutputType([int])]
  param(
    [string[]]$Patterns,
    [string]$Text,
    [bool]$IgnoreCase = $true
  )
  if (-not $Text -or -not $Patterns)
  {
    return $null
  }
  $cmp = if ($IgnoreCase)
  {
    [System.StringComparison]::OrdinalIgnoreCase
  } else
  {
    [System.StringComparison]::Ordinal
  }
  $bestLength = 0
  foreach ($pattern in $Patterns)
  {
    if ([string]::IsNullOrEmpty($pattern))
    {
      continue
    }
    if ($Text.StartsWith($pattern, $cmp) -and $pattern.Length -gt $bestLength)
    {
      $bestLength = $pattern.Length
    }
  }
  if ($bestLength -gt 0)
  {
    return $bestLength
  } else
  {
    return $null
  }
}

function Show-HilightedList
{
  param(
    [string[]]$List,
    [string[]]$Pattern
  )
  foreach($target in $List)
  {
    $hlength = Get-PrefixMatchIndices -Patterns $Pattern -Text $target
    if ($hlength)
    {
      $prefix = $target.Substring(0, $hlength)
      $suffix = $target.Substring($hlength)
      Write-Host "$prefix" -ForegroundColor DarkGray -NoNewline
      Write-Host "$suffix"
    } else
    {
      Write-Host "$target"
    }
  }
}

# Only Show
$UserEnvPath = "HKCU:\Environment"
Write-Host "User Environment Variables:" -ForegroundColor Cyan
$UserEnvPathes = (Get-ItemPropertyValue -Path $UserEnvPath -Name Path) -split ';'
Show-HilightedList -List $UserEnvPathes -Pattern $HilightPattern
$SystemEnvPath = "HKLM:\System\CurrentControlSet\Control\Session Manager\Environment"
Write-Host "System Environment Variables:" -ForegroundColor Cyan
$SystemEnvPathes = (Get-ItemPropertyValue -Path $SystemEnvPath -Name Path) -split ';'
Show-HilightedList -List $SystemEnvPathes -Pattern $HilightPattern

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
  "emacs",
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
  # Tool
  "mise",
  "tshark",
  "ffmpeg",
  "imagick",
  "nmap",
  "csvlens",
  "inkscape",
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

