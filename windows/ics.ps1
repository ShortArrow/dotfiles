<#
Set-ICS-Interactive.ps1

Interactive Internet Connection Sharing (ICS) controller:
- Shows a numbered list of network connections
- Lets the user pick Public (Internet-facing) and Private (shared-side) interfaces
- Enables/disables ICS via HNetCfg.HNetShare COM
- Optionally overrides Private-side IPv4/DNS after enabling ICS (guard clauses / early returns)
#>

[CmdletBinding()]
param(
    [ValidateSet("Enable","Disable")]
    [string]$Mode = "Enable",

    # Enable static IPv4/DNS configuration override for the Private interface after enabling ICS
    [switch]$ConfigurePrivateIP,

    # Static IPv4 configuration for Private interface
    [string]$PrivateIPv4Address,      # e.g. 10.10.0.1
    [string]$PrivateSubnetMask,       # e.g. 255.255.255.0
    [string]$PrivateDefaultGateway,   # optional
    [string[]]$PrivateDnsServers      # optional, e.g. 1.1.1.1,8.8.8.8
)

function Assert-Admin {
    # Ensure the script is running with administrative privileges
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Please run this script as Administrator."
    }
}

function Ensure-ICSServiceRunning {
    # ICS service name is SharedAccess
    # Force it to auto-start and ensure it is running
    & sc.exe config SharedAccess start= auto | Out-Null
    & sc.exe start  SharedAccess            | Out-Null
}

function New-HNetShare {
    # Create HNetCfg.HNetShare COM object
    try {
        return New-Object -ComObject HNetCfg.HNetShare
    } catch {
        throw "Failed to create HNetCfg.HNetShare COM object. Details: $($_.Exception.Message)"
    }
}

function Get-Connections([object]$hnet) {
    # Enumerate all network connections known to HNetShare
    $list = New-Object System.Collections.Generic.List[object]
    foreach ($c in @($hnet.EnumEveryConnection())) {
        $p = $hnet.NetConnectionProps($c)
        $list.Add([pscustomobject]@{
            Name       = $p.Name       # Connection name shown in ncpa.cpl
            DeviceName = $p.DeviceName # Adapter description
            Guid       = $p.Guid
            Status     = $p.Status
            MediaType  = $p.MediaType
            _Conn      = $c             # Raw COM connection object
        })
    }
    # Sort for stable and readable menu output
    return $list | Sort-Object Name
}

function Show-Menu($connections) {
    # Display numbered list of network connections
    Write-Host ""
    Write-Host "=== Network Connections (select by number) ==="
    for ($i = 0; $i -lt $connections.Count; $i++) {
        $c = $connections[$i]
        Write-Host ("[{0,2}] {1}  ({2})" -f $i, $c.Name, $c.DeviceName)
    }
    Write-Host ""
}

function Read-Index([string]$prompt, [int]$maxExclusive) {
    # Read a numeric index from user input
    while ($true) {
        $s = Read-Host $prompt
        if ($s -match '^\d+$') {
            $n = [int]$s
            if (0 -le $n -and $n -lt $maxExclusive) { return $n }
        }
        Write-Host "Please enter a number between 0 and $($maxExclusive-1)." -ForegroundColor Yellow
    }
}

function Disable-SharingIfEnabled([object]$cfg) {
    # Disable ICS sharing if already enabled
    if ($cfg.SharingEnabled) {
        $cfg.DisableSharing() | Out-Null
    }
}

function Enable-ICS([object]$hnet, [object]$pubConn, [object]$priConn) {
    # Enable Internet Connection Sharing
    $pubCfg = $hnet.INetSharingConfigurationForINetConnection($pubConn)
    $priCfg = $hnet.INetSharingConfigurationForINetConnection($priConn)

    # Disable existing sharing first to avoid conflicts
    Disable-SharingIfEnabled $pubCfg
    Disable-SharingIfEnabled $priCfg

    # 0 = Public (Internet side), 1 = Private (shared side)
    $pubCfg.EnableSharing(0) | Out-Null
    $priCfg.EnableSharing(1) | Out-Null

    return @($pubCfg, $priCfg)
}

function Disable-ICS([object]$hnet, [object]$pubConn, [object]$priConn) {
    # Disable Internet Connection Sharing
    $pubCfg = $hnet.INetSharingConfigurationForINetConnection($pubConn)
    $priCfg = $hnet.INetSharingConfigurationForINetConnection($priConn)

    Disable-SharingIfEnabled $pubCfg
    Disable-SharingIfEnabled $priCfg

    return @($pubCfg, $priCfg)
}

function Convert-SubnetMaskToPrefixLength([string]$mask) {
    # Convert subnet mask (e.g. 255.255.255.0) to prefix length (e.g. 24)
    $bytes = $mask.Split('.')
    if ($bytes.Count -ne 4) { throw "Invalid subnet mask format: $mask" }

    $prefix = 0
    foreach ($b in $bytes) {
        if (-not ($b -match '^\d+$')) { throw "Invalid subnet mask format: $mask" }
        $v = [int]$b
        if ($v -lt 0 -or $v -gt 255) { throw "Invalid subnet mask format: $mask" }

        $bin = [Convert]::ToString($v, 2).PadLeft(8, '0')
        # Only contiguous 1-bits are allowed
        if ($bin -match '01.*1') { throw "Subnet mask is not contiguous: $mask" }
        $prefix += ($bin.ToCharArray() | Where-Object { $_ -eq '1' }).Count
    }
    return $prefix
}

function Resolve-PrivateInterfaceAlias([string]$privateConnectionName) {
    # HNetShare connection name usually matches InterfaceAlias, but not always.
    # Try exact match first, then fallback to partial match.
    $alias = $privateConnectionName
    $adapter = Get-NetAdapter -Name $alias -ErrorAction SilentlyContinue
    if ($adapter) { return $adapter.Name }

    $adapter = Get-NetAdapter | Where-Object { $_.Name -like "*$alias*" } | Select-Object -First 1
    if ($adapter) { return $adapter.Name }

    throw "Private interface not found for IP configuration: $privateConnectionName"
}

function Apply-PrivateStaticIPv4 {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PrivateConnectionName,   # usually equals InterfaceAlias (ncpa.cpl name)

        [Parameter(Mandatory=$true)]
        [string]$IPv4Address,

        [Parameter(Mandatory=$true)]
        [string]$SubnetMask,

        [string]$DefaultGateway,
        [string[]]$DnsServers
    )

    # Resolve adapter alias for NetTCPIP cmdlets
    $alias = Resolve-PrivateInterfaceAlias $PrivateConnectionName

    $prefix = Convert-SubnetMaskToPrefixLength $SubnetMask

    # Remove existing IPv4 addresses (typically 192.168.137.1 assigned by ICS)
    $existing = Get-NetIPAddress -InterfaceAlias $alias -AddressFamily IPv4 -ErrorAction SilentlyContinue
    foreach ($ip in @($existing)) {
        if ($ip.IPAddress -ne $IPv4Address) {
            try {
                Remove-NetIPAddress -InterfaceAlias $alias -IPAddress $ip.IPAddress -Confirm:$false -ErrorAction Stop
            } catch {
                # Ignore environment-dependent failures
            }
        }
    }

    # Add or update the desired static IPv4 address
    $desired = Get-NetIPAddress -InterfaceAlias $alias -AddressFamily IPv4 -IPAddress $IPv4Address -ErrorAction SilentlyContinue
    if (-not $desired) {
        if ($DefaultGateway) {
            New-NetIPAddress -InterfaceAlias $alias -IPAddress $IPv4Address -PrefixLength $prefix -DefaultGateway $DefaultGateway | Out-Null
        } else {
            New-NetIPAddress -InterfaceAlias $alias -IPAddress $IPv4Address -PrefixLength $prefix | Out-Null
        }
    } else {
        if ($DefaultGateway) {
            Set-NetIPAddress -InterfaceAlias $alias -IPAddress $IPv4Address -PrefixLength $prefix -DefaultGateway $DefaultGateway | Out-Null
        } else {
            Set-NetIPAddress -InterfaceAlias $alias -IPAddress $IPv4Address -PrefixLength $prefix | Out-Null
        }
    }

    # Configure DNS servers if specified
    if ($DnsServers -and $DnsServers.Count -gt 0) {
        Set-DnsClientServerAddress -InterfaceAlias $alias -ServerAddresses $DnsServers | Out-Null
    }

    Write-Host ""
    Write-Host "Static IPv4/DNS configuration applied to Private interface: $alias"
    Get-NetIPConfiguration -InterfaceAlias $alias | Format-List
}

# ---- main ----
Assert-Admin

# Ensure the ICS service is running before enabling sharing
if ($Mode -eq "Enable") {
    Ensure-ICSServiceRunning
}

$hnet = New-HNetShare
$connections = @(Get-Connections $hnet)

if ($connections.Count -lt 2) {
    throw "At least two network connections are required."
}

Show-Menu $connections

$pubIdx = Read-Index "Select Public (Internet-facing) interface number"  $connections.Count
$priIdx = Read-Index "Select Private (shared) interface number"         $connections.Count

if ($pubIdx -eq $priIdx) {
    throw "Public and Private interfaces must be different."
}

$pub = $connections[$pubIdx]
$pri = $connections[$priIdx]

Write-Host ""
Write-Host "Selected:"
Write-Host "  Public : [$pubIdx] $($pub.Name)"
Write-Host "  Private: [$priIdx] $($pri.Name)"
Write-Host ""

try {
    if ($Mode -eq "Enable") {
        $cfgs = Enable-ICS $hnet $pub._Conn $pri._Conn
        Write-Host "ICS enabled. SharingEnabled: pub=$($cfgs[0].SharingEnabled) pri=$($cfgs[1].SharingEnabled)"
    } else {
        $cfgs = Disable-ICS $hnet $pub._Conn $pri._Conn
        Write-Host "ICS disabled. SharingEnabled: pub=$($cfgs[0].SharingEnabled) pri=$($cfgs[1].SharingEnabled)"
    }
} catch {
    throw "ICS operation failed: $($_.Exception.Message)"
}

# --- Guard clauses / early returns for optional Private IP override ---
if ($Mode -ne "Enable") { return }
if (-not $ConfigurePrivateIP) { return }

# Validate required parameters only when the switch is used
if (-not $PrivateIPv4Address -or -not $PrivateSubnetMask) {
    throw "When -ConfigurePrivateIP is specified, -PrivateIPv4Address and -PrivateSubnetMask are required."
}

Apply-PrivateStaticIPv4 `
    -PrivateConnectionName $pri.Name `
    -IPv4Address $PrivateIPv4Address `
    -SubnetMask $PrivateSubnetMask `
    -DefaultGateway $PrivateDefaultGateway `
    -DnsServers $PrivateDnsServers

