#!/usr/bin/env pwsh

<#
.SYNOPSIS
  Find and recover windows GlazeWM cloaked and then lost track of.

.DESCRIPTION
  GlazeWM hides windows on inactive workspaces by DWM-cloaking them, not by
  moving them off-screen. A GlazeWM restart does not enumerate cloaked windows,
  so a window that sat on an inactive workspace keeps its cloak while losing its
  manager. Such a window reports WS_VISIBLE and an on-screen rectangle yet is
  drawn on no workspace, and raising the z-order does not reveal it.

  A cloak is clearable only by the process owning the window, so recovery is
  per-application. wezterm exposes a per-process control socket, so its panes
  can be moved into a freshly created window, which carries no cloak.
  Applications without an equivalent interface are reported, not recovered.

  Called with no switch, lists what is stranded and what is merely unmanaged;
  the `ignore` rules in config.yaml legitimately produce the latter.

.PARAMETER Rescue
  Attempt recovery of the matched stranded windows.

.PARAMETER ProcessId
  Restrict the operation to these owning processes.

.PARAMETER Handle
  Restrict the operation to these window handles.

.EXAMPLE
  ./glazewm/rescue-window.ps1
  Lists stranded windows and unmanaged-but-drawn windows.

.EXAMPLE
  ./glazewm/rescue-window.ps1 -Rescue -ProcessId 11268
  Consolidates that wezterm process's panes into a new, uncloaked window.
#>
param(
  [switch]$Rescue,
  [int[]]$ProcessId,
  [int[]]$Handle
)

$ErrorActionPreference = 'Stop'

Add-Type -Namespace GlazeRescue -Name Win -MemberDefinition @'
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
  public delegate bool EnumProc(IntPtr hWnd, IntPtr lParam);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb, IntPtr lParam);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT r);
  [DllImport("user32.dll")] public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern int GetWindowTextW(IntPtr hWnd, System.Text.StringBuilder s, int n);
  [DllImport("dwmapi.dll")] public static extern int DwmGetWindowAttribute(IntPtr hWnd, int attr, out int val, int size);
  [DllImport("user32.dll")] public static extern bool IsImmersiveProcess(IntPtr hProcess);
  [DllImport("kernel32.dll")] public static extern IntPtr OpenProcess(int access, bool inherit, int pid);
  [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr h);
'@

$DWMWA_CLOAKED = 14
$GWL_EXSTYLE = -20
$WS_EX_TOOLWINDOW = 0x00000080
$PROCESS_QUERY_LIMITED_INFORMATION = 0x1000

function Write-RescueWarn {
  param([Parameter(Mandatory)][string]$Message)
  Write-Host -ForegroundColor Yellow "  $Message"
}

function Get-CloakState {
  <#
  .SYNOPSIS
    DWM cloak value: 0 none, 1 app, 2 shell (what GlazeWM uses), 4 inherited.
    Returns -1 when DWM refuses the query.
  #>
  param([Parameter(Mandatory)][int]$WindowHandle)

  $value = 0
  $hr = [GlazeRescue.Win]::DwmGetWindowAttribute([IntPtr]$WindowHandle, $DWMWA_CLOAKED, [ref]$value, 4)
  if ($hr -ne 0) { return -1 }
  $value
}

function Test-ImmersiveProcess {
  <#
  .SYNOPSIS
    True for UWP processes, whose windows the shell cloaks on suspend for
    reasons unrelated to GlazeWM.
  #>
  param([Parameter(Mandatory)][int]$OwnerPid)

  $handle = [GlazeRescue.Win]::OpenProcess($PROCESS_QUERY_LIMITED_INFORMATION, $false, $OwnerPid)
  if ($handle -eq [IntPtr]::Zero) { return $false }
  try { [GlazeRescue.Win]::IsImmersiveProcess($handle) }
  finally { [void][GlazeRescue.Win]::CloseHandle($handle) }
}

function Get-ManagedHandle {
  <#
  .SYNOPSIS
    Window handles GlazeWM currently manages; empty when GlazeWM is not running.
  #>
  $raw = glazewm query windows 2>$null | Out-String
  if (-not $raw.Trim()) { return @() }
  try { , @(($raw | ConvertFrom-Json).data.windows.handle) }
  catch { , @() }
}

function Get-CandidateWindow {
  <#
  .SYNOPSIS
    Titled top-level windows that are neither minimized nor tool windows.
  #>
  $found = [System.Collections.Generic.List[psobject]]::new()
  $callback = [GlazeRescue.Win+EnumProc] {
    param($hWnd, $lParam)

    if (-not [GlazeRescue.Win]::IsWindowVisible($hWnd)) { return $true }
    if ([GlazeRescue.Win]::IsIconic($hWnd)) { return $true }
    if (([GlazeRescue.Win]::GetWindowLong($hWnd, $GWL_EXSTYLE) -band $WS_EX_TOOLWINDOW) -ne 0) { return $true }

    $buffer = New-Object System.Text.StringBuilder 512
    [void][GlazeRescue.Win]::GetWindowTextW($hWnd, $buffer, $buffer.Capacity)
    $title = $buffer.ToString()
    if (-not $title) { return $true }

    $owner = [uint32]0
    [void][GlazeRescue.Win]::GetWindowThreadProcessId($hWnd, [ref]$owner)
    $rect = New-Object GlazeRescue.Win+RECT
    [void][GlazeRescue.Win]::GetWindowRect($hWnd, [ref]$rect)

    $found.Add([pscustomobject]@{
        Handle    = [int]$hWnd
        Pid       = [int]$owner
        Process   = (Get-Process -Id $owner -ErrorAction SilentlyContinue).ProcessName
        Title     = $title
        Rect      = "L=$($rect.Left) T=$($rect.Top) R=$($rect.Right) B=$($rect.Bottom)"
        Cloaked   = Get-CloakState -WindowHandle ([int]$hWnd)
        Immersive = Test-ImmersiveProcess -OwnerPid ([int]$owner)
      })
    return $true
  }
  [void][GlazeRescue.Win]::EnumWindows($callback, [IntPtr]::Zero)
  $found
}

function Restore-WeztermProcess {
  <#
  .SYNOPSIS
    Consolidate every pane of one wezterm process into a new, uncloaked window.

  .DESCRIPTION
    Drives the per-process gui socket so wezterm itself creates the window.
    Every pane the process owns is gathered, including panes that already sat in
    an uncloaked window of that same process.
  #>
  param([Parameter(Mandatory)][int]$OwnerPid)

  $socket = Join-Path $env:USERPROFILE ".local/share/wezterm/gui-sock-$OwnerPid"
  if (-not (Test-Path -LiteralPath $socket)) {
    Write-RescueWarn "no wezterm control socket at $socket"
    return $false
  }

  $previous = $env:WEZTERM_UNIX_SOCKET
  $env:WEZTERM_UNIX_SOCKET = $socket
  try {
    $panes = @(wezterm cli list --format json 2>$null | ConvertFrom-Json)
    if (-not $panes) {
      Write-RescueWarn "pid $OwnerPid exposed no panes"
      return $false
    }

    $windowsBefore = @($panes.window_id | Sort-Object -Unique)
    $paneIds = @($panes.pane_id)

    wezterm cli move-pane-to-new-tab --pane-id $paneIds[0] --new-window | Out-Null

    $windowsAfter = @((wezterm cli list --format json 2>$null | ConvertFrom-Json).window_id | Sort-Object -Unique)
    $target = @($windowsAfter | Where-Object { $windowsBefore -notcontains $_ })
    if ($target.Count -ne 1) {
      Write-RescueWarn "could not identify the new wezterm window for pid $OwnerPid"
      return $false
    }

    foreach ($pane in @($paneIds | Select-Object -Skip 1)) {
      wezterm cli move-pane-to-new-tab --pane-id $pane --window-id $target[0] | Out-Null
    }
    Write-Host -ForegroundColor Green "  recovered into wezterm window $($target[0]) ($($paneIds.Count) pane(s))"
    return $true
  }
  finally { $env:WEZTERM_UNIX_SOCKET = $previous }
}

$managed = Get-ManagedHandle
$candidates = Get-CandidateWindow | Where-Object { $managed -notcontains $_.Handle }

if ($ProcessId) { $candidates = $candidates | Where-Object { $ProcessId -contains $_.Pid } }
if ($Handle) { $candidates = $candidates | Where-Object { $Handle -contains $_.Handle } }

$stranded = @($candidates | Where-Object { $_.Cloaked -gt 0 -and -not $_.Immersive })
$drawn = @($candidates | Where-Object { $_.Cloaked -eq 0 })
$suspendedUwp = @($candidates | Where-Object { $_.Cloaked -gt 0 -and $_.Immersive })

if (-not $Rescue) {
  Write-Host -ForegroundColor Cyan "Stranded — cloaked but unmanaged, drawn on no workspace ($($stranded.Count)):"
  if ($stranded) { $stranded | Format-Table Handle, Pid, Process, Cloaked, Rect, Title -AutoSize }
  Write-Host -ForegroundColor Cyan "Unmanaged but drawn — expected for the ignore rules in config.yaml ($($drawn.Count)):"
  if ($drawn) { $drawn | Format-Table Handle, Pid, Process, Rect, Title -AutoSize }
  Write-Host -ForegroundColor DarkGray "Suspended UWP windows, cloaked by the shell and not GlazeWM's doing: $($suspendedUwp.Count)"
  return
}

if (-not $stranded) {
  Write-Host -ForegroundColor Green 'Nothing stranded.'
  return
}

foreach ($group in $stranded | Group-Object Pid) {
  $owner = [int]$group.Name
  $process = $group.Group[0].Process
  Write-Host -ForegroundColor Cyan "pid $owner [$process] $($group.Count) window(s)"

  switch ($process) {
    'wezterm-gui' { [void](Restore-WeztermProcess -OwnerPid $owner) }
    default {
      Write-RescueWarn "no recovery path for '$process'"
      Write-RescueWarn "a cloak is clearable only by its owning process — restart the app, or"
      Write-RescueWarn "restart explorer.exe to reset shell cloaks across all windows"
    }
  }
}
