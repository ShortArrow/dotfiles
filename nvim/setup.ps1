#! pwsh

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$targetDirectory = "$env:LOCALAPPDATA"
$sourceDirectory = "$scriptDirectory/src"

$item = "nvim"
$targetPath = "$targetDirectory/$item"

# Check Developer Mode (Windows 10 1703 or later)
$devModeKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
$devModeEnabled = $false

if (Test-Path $devModeKey) {
    $value = Get-ItemProperty -Path $devModeKey -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
    if ($value.AllowDevelopmentWithoutDevLicense -eq 1) {
        $devModeEnabled = $true
    }
}

# Check Administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $devModeEnabled -and -not $isAdmin) {
    Write-Host "Warning: Developer Mode is disabled and no Administrator privileges." -ForegroundColor Yellow
    Write-Host "Creating symbolic links requires one of the following:" -ForegroundColor Yellow
    Write-Host "  1. Enable Developer Mode (Settings > Update & Security > For developers)" -ForegroundColor Cyan
    Write-Host "  2. Run this script as Administrator" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Continue anyway? (may fail) [y/N]: " -NoNewline -ForegroundColor Yellow
    $response = Read-Host
    if ($response -ne 'y' -and $response -ne 'Y') {
        Write-Host "Aborted." -ForegroundColor Red
        exit 1
    }
}

# Remove existing symbolic link or directory
if (Test-Path $targetPath) {
    Remove-Item $targetPath -Force -Recurse -ErrorAction SilentlyContinue
}

# Create symbolic link
try {
    New-Item -ItemType SymbolicLink -Path $targetPath -Value $sourceDirectory -Force -ErrorAction Stop | Out-Null
    Write-Host "✓ Symbolic link created successfully:" -ForegroundColor Green
    Get-ChildItem -Path $env:LOCALAPPDATA -Force -ErrorAction 'silentlycontinue' |
        Where-Object { $_.Attributes -match "ReparsePoint" -and $_.Name -match "$item" } |
        ForEach-Object {
            Write-Host "  $($_.FullName) -> $($_.Target)" -ForegroundColor Cyan
        }
} catch {
    Write-Host "✗ Error: Failed to create symbolic link." -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

