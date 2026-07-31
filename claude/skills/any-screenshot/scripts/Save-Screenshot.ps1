#!pwsh

<#
.SYNOPSIS
  Capture every monitor into one PNG and print the path.

.DESCRIPTION
  Copies the virtual screen — the bounding box of all monitors — through
  GDI. Requires an interactive desktop: a session without one (an SSH
  session, a disconnected RDP session) has no window station to copy from
  and yields a black image without raising an error. Run it through
  Invoke-ScreenshotViaTask.ps1 in that case.

  Prints the saved path on stdout so a caller can read the file back.

.PARAMETER Path
  Destination PNG. Defaults to a timestamped file under
  <MyPictures>\Screenshots.

.PARAMETER SettleMilliseconds
  Delay before capturing, to let a just-triggered UI change finish
  painting.

.EXAMPLE
  ./Save-Screenshot.ps1 -Path C:/temp/before.png
#>
param(
  [string]$Path,
  [int]$SettleMilliseconds = 800
)

$ErrorActionPreference = 'Stop'

if ($SettleMilliseconds -gt 0) { Start-Sleep -Milliseconds $SettleMilliseconds }

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

if (-not $Path)
{
  $saveDir = Join-Path ([Environment]::GetFolderPath('MyPictures')) 'Screenshots'
  $Path = Join-Path $saveDir "screenshot-$(Get-Date -Format 'yyyyMMdd-HHmmss').png"
}

$parent = Split-Path -Parent $Path
if ($parent -and -not (Test-Path -LiteralPath $parent))
{
  New-Item -ItemType Directory -Path $parent -Force | Out-Null
}

$bounds = [System.Windows.Forms.SystemInformation]::VirtualScreen
$bmp = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
$graphics = [System.Drawing.Graphics]::FromImage($bmp)
try
{
  $graphics.CopyFromScreen(
    [int]$bounds.Left,
    [int]$bounds.Top,
    0,
    0,
    $bounds.Size,
    [System.Drawing.CopyPixelOperation]::SourceCopy
  )
  $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
} finally
{
  $graphics.Dispose()
  $bmp.Dispose()
}

Write-Output $Path
