<#
.SYNOPSIS
Read and clear the kana lock (VK_KANA) toggle.

.DESCRIPTION
With kana lock on, a field that turns the IME off (a password field, pinentry)
receives letters as half-width kana from the JIS kana layout, whatever mode the
IME shows. A 101-key keyboard has no kana key to clear it by hand.

The user32 calls come from a small assembly compiled once into CacheDir:
compiling it on every start costs ~0.9 s, loading it ~6 ms.
#>

$script:KanaLockTypeName = 'DotfilesKana.User32'
$script:VkKana = 0x15

function Test-KeyToggled {
    <# .SYNOPSIS True when a GetKeyState result has its toggle bit (low bit) set. #>
    param([Parameter(Mandatory)][int16]$State)
    ($State -band 1) -ne 0
}

function Import-KanaLockNative {
    <# .SYNOPSIS Loads the user32 bindings, compiling them into CacheDir on first use. #>
    param([Parameter(Mandatory)][string]$CacheDir)
    if ($script:KanaLockTypeName -as [type]) { return }
    $dll = Join-Path $CacheDir 'DotfilesKana.v1.dll'
    if (-not (Test-Path -LiteralPath $dll)) {
        New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
        Add-Type -Namespace DotfilesKana -Name User32 -OutputAssembly $dll -MemberDefinition @'
[DllImport("user32.dll")] public static extern short GetKeyState(int vKey);
[DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, System.UIntPtr dwExtraInfo);
'@
    }
    $null = [Reflection.Assembly]::LoadFile($dll)
}

function Get-KanaLock {
    <# .SYNOPSIS True when kana lock is on. #>
    param([string]$CacheDir = (Join-Path $HOME '.cache/pwsh-native'))
    Import-KanaLockNative -CacheDir $CacheDir
    Test-KeyToggled -State ([DotfilesKana.User32]::GetKeyState($script:VkKana))
}

function Disable-KanaLock {
    <# .SYNOPSIS Turns kana lock off by sending one kana key press; does nothing when it is already off. #>
    param([string]$CacheDir = (Join-Path $HOME '.cache/pwsh-native'))
    if (-not (Get-KanaLock -CacheDir $CacheDir)) { return }
    $keyUp = 2
    [DotfilesKana.User32]::keybd_event($script:VkKana, 0, 0, [UIntPtr]::Zero)
    [DotfilesKana.User32]::keybd_event($script:VkKana, 0, $keyUp, [UIntPtr]::Zero)
}
