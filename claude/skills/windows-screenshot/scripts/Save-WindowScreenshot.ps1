#!pwsh

<#
.SYNOPSIS
  Capture the windows of a process by PID, one PNG per window.

.DESCRIPTION
  Renders each top-level window through PrintWindow with
  PW_RENDERFULLCONTENT, which asks the window to draw itself into a
  bitmap. Unlike a screen-region copy this works when the window is
  behind another one, and it works for GPU-composited windows that
  return black from a plain BitBlt.

  Two states produce an image with nothing in it, so both are reported
  instead of being written out silently:

  - Minimized. The window has no current surface to draw.
  - DWM-cloaked. The window is alive but hidden by the shell — a
    suspended UWP app, or a tiling manager holding it on an unviewed
    workspace. It is invisible and uncapturable until uncloaked.

  Prints the saved path of each capture on stdout.

.PARAMETER ProcessId
  Target process. Every visible top-level window it owns is captured.

.PARAMETER TitleMatch
  Regex filter over window titles, for a process owning several windows.

.PARAMETER Path
  Destination PNG. With several matching windows an index is appended
  before the extension. Defaults to a timestamped file under
  <MyPictures>\Screenshots.

.PARAMETER List
  Report the matching windows and exit without capturing.

.PARAMETER IncludeEmpty
  Capture minimized and cloaked windows anyway, instead of skipping them.

.EXAMPLE
  ./Save-WindowScreenshot.ps1 -ProcessId 11268 -List

.EXAMPLE
  ./Save-WindowScreenshot.ps1 -ProcessId 11268 -TitleMatch 'dotfiles' -Path C:/temp/w.png
#>
param(
  [Parameter(Mandatory)][int]$ProcessId,
  [string]$TitleMatch,
  [string]$Path,
  [switch]$List,
  [switch]$IncludeEmpty
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

if (-not ('DotfilesWindowCapture' -as [type]))
{
  Add-Type -Language CSharp @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;

public class DotfilesWindow
{
    public IntPtr Handle;
    public string Title;
    public int Left, Top, Width, Height;
    public bool IsMinimized, IsCloaked;
}

public static class DotfilesWindowCapture
{
    private const int DWMWA_EXTENDED_FRAME_BOUNDS = 9;
    private const int DWMWA_CLOAKED = 14;
    private const uint PW_RENDERFULLCONTENT = 0x2;

    [StructLayout(LayoutKind.Sequential)]
    private struct RECT { public int Left, Top, Right, Bottom; }

    private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")] private static extern bool EnumWindows(EnumWindowsProc cb, IntPtr p);
    [DllImport("user32.dll")] private static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
    [DllImport("user32.dll")] private static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll")] private static extern bool IsIconic(IntPtr h);
    [DllImport("user32.dll")] private static extern int GetWindowTextLengthW(IntPtr h);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] private static extern int GetWindowTextW(IntPtr h, StringBuilder s, int max);
    [DllImport("user32.dll")] private static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] private static extern bool PrintWindow(IntPtr h, IntPtr hdc, uint flags);
    [DllImport("dwmapi.dll")] private static extern int DwmGetWindowAttribute(IntPtr h, int attr, out RECT r, int size);
    [DllImport("dwmapi.dll")] private static extern int DwmGetWindowAttribute(IntPtr h, int attr, out int v, int size);

    public static List<DotfilesWindow> ForProcess(uint targetPid)
    {
        var found = new List<DotfilesWindow>();
        EnumWindows(delegate (IntPtr hWnd, IntPtr unused)
        {
            uint pid;
            GetWindowThreadProcessId(hWnd, out pid);
            if (pid != targetPid) return true;
            if (!IsWindowVisible(hWnd)) return true;

            int length = GetWindowTextLengthW(hWnd);
            var sb = new StringBuilder(length + 1);
            GetWindowTextW(hWnd, sb, sb.Capacity);

            RECT bounds;
            // The extended frame bounds exclude the invisible resize border
            // Windows 10+ reports through GetWindowRect, which would add a
            // transparent margin to every capture.
            if (DwmGetWindowAttribute(hWnd, DWMWA_EXTENDED_FRAME_BOUNDS, out bounds, Marshal.SizeOf(typeof(RECT))) != 0)
            {
                GetWindowRect(hWnd, out bounds);
            }

            int cloaked;
            if (DwmGetWindowAttribute(hWnd, DWMWA_CLOAKED, out cloaked, sizeof(int)) != 0) cloaked = 0;

            found.Add(new DotfilesWindow
            {
                Handle = hWnd,
                Title = sb.ToString(),
                Left = bounds.Left,
                Top = bounds.Top,
                Width = bounds.Right - bounds.Left,
                Height = bounds.Bottom - bounds.Top,
                IsMinimized = IsIconic(hWnd),
                IsCloaked = cloaked != 0
            });
            return true;
        }, IntPtr.Zero);
        return found;
    }

    public static bool Render(IntPtr hWnd, IntPtr hdc)
    {
        return PrintWindow(hWnd, hdc, PW_RENDERFULLCONTENT);
    }
}
'@
}

$process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
if (-not $process) { throw "No process with PID $ProcessId." }

$windows = @([DotfilesWindowCapture]::ForProcess([uint32]$ProcessId))
if ($TitleMatch) { $windows = @($windows | Where-Object { $_.Title -match $TitleMatch }) }

if ($windows.Count -eq 0)
{
  throw "PID $ProcessId ($($process.ProcessName)) owns no visible top-level window matching the filter."
}

if ($List)
{
  $windows | ForEach-Object {
    [PSCustomObject]@{
      Handle    = '0x{0:X}' -f [int64]$_.Handle
      Title     = $_.Title
      Size      = "$($_.Width)x$($_.Height)"
      Minimized = $_.IsMinimized
      Cloaked   = $_.IsCloaked
    }
  }
  return
}

$capturable = if ($IncludeEmpty) { $windows } else { @($windows | Where-Object { -not $_.IsMinimized -and -not $_.IsCloaked }) }

foreach ($skipped in $windows | Where-Object { $_.IsMinimized -or $_.IsCloaked })
{
  $why = if ($skipped.IsCloaked) { 'DWM-cloaked (hidden by the shell)' } else { 'minimized' }
  Write-Warning "Skipping '$($skipped.Title)': $why — it would capture as blank. Use -IncludeEmpty to override."
}

if ($capturable.Count -eq 0) { throw "Every matching window is minimized or cloaked; nothing to capture." }

if (-not $Path)
{
  $saveDir = Join-Path ([Environment]::GetFolderPath('MyPictures')) 'Screenshots'
  $Path = Join-Path $saveDir "$($process.ProcessName)-$(Get-Date -Format 'yyyyMMdd-HHmmss').png"
}
$parent = Split-Path -Parent $Path
if ($parent -and -not (Test-Path -LiteralPath $parent))
{
  New-Item -ItemType Directory -Path $parent -Force | Out-Null
}

$index = 0
foreach ($window in $capturable)
{
  $index++
  $target = if ($capturable.Count -eq 1)
  {
    $Path
  } else
  {
    Join-Path (Split-Path -Parent $Path) ("{0}-{1}{2}" -f [IO.Path]::GetFileNameWithoutExtension($Path), $index, [IO.Path]::GetExtension($Path))
  }

  $bmp = New-Object System.Drawing.Bitmap $window.Width, $window.Height
  $graphics = [System.Drawing.Graphics]::FromImage($bmp)
  $hdc = $graphics.GetHdc()
  try
  {
    $rendered = [DotfilesWindowCapture]::Render($window.Handle, $hdc)
  } finally
  {
    $graphics.ReleaseHdc($hdc)
  }
  $graphics.Dispose()

  if (-not $rendered)
  {
    $bmp.Dispose()
    Write-Warning "PrintWindow refused '$($window.Title)'."
    continue
  }

  $bmp.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Output $target
}
