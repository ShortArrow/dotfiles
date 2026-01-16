<#
Set-ICS-Interactive.ps1

Interactive Internet Connection Sharing (ICS) controller:
- Shows a numbered list of network connections
- Lets the user pick Public (Internet-facing) and Private (shared-side) interfaces
- Enables/disables ICS via HNetCfg.HNetShare COM
- Optionally overrides Private-side IPv4/DNS after enabling ICS
#>

[CmdletBinding()]
param(
  [ValidateSet("Enable", "Disable")]
  [string]$Mode = "Enable",

  [switch]$ConfigurePrivateIP,

  [string]$PrivateIPv4Address,    # e.g. 192.168.123.1
  [string]$PrivateSubnetMask,     # e.g. 255.255.255.0
  [string[]]$PrivateDnsServers    # e.g. 1.1.1.1,8.8.8.8
)

# ICS always assigns this IP to the Private interface
$script:ICS_DEFAULT_IP = "192.168.137.1"

#region Helper Functions

function Assert-Admin
{
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($id)
  if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
  {
    throw "Please run this script as Administrator."
  }
}

function Ensure-ICSServiceRunning
{
  & sc.exe config SharedAccess start= auto | Out-Null
  & sc.exe start  SharedAccess            | Out-Null
}

function New-HNetShare
{
  try
  {
    return New-Object -ComObject HNetCfg.HNetShare
  }
  catch
  {
    throw "Failed to create HNetCfg.HNetShare COM object: $($_.Exception.Message)"
  }
}

function Get-Connections([object]$hnet)
{
  $list = [System.Collections.Generic.List[object]]::new()
  foreach ($conn in @($hnet.EnumEveryConnection()))
  {
    $props = $hnet.NetConnectionProps($conn)
    $list.Add([pscustomobject]@{
        Name       = $props.Name
        DeviceName = $props.DeviceName
        Guid       = $props.Guid
        Status     = $props.Status
        MediaType  = $props.MediaType
        _Conn      = $conn
      })
  }
  return $list | Sort-Object Name
}

function Show-Menu([object[]]$connections)
{
  Write-Host ""
  Write-Host "=== Network Connections ==="
  for ($i = 0; $i -lt $connections.Count; $i++)
  {
    $c = $connections[$i]
    Write-Host ("[{0,2}] {1}  ({2})" -f $i, $c.Name, $c.DeviceName)
  }
  Write-Host ""
}

function Read-Index([string]$prompt, [int]$max)
{
  while ($true)
  {
    $input = Read-Host $prompt
    if ($input -match '^\d+$')
    {
      $n = [int]$input
      if ($n -ge 0 -and $n -lt $max) { return $n }
    }
    Write-Host "Enter a number between 0 and $($max - 1)." -ForegroundColor Yellow
  }
}

function Convert-SubnetMaskToPrefix([string]$mask)
{
  $octets = $mask.Split('.')
  if ($octets.Count -ne 4) { throw "Invalid subnet mask: $mask" }

  $prefix = 0
  foreach ($octet in $octets)
  {
    $val = [int]$octet
    if ($val -lt 0 -or $val -gt 255) { throw "Invalid subnet mask: $mask" }
    $bin = [Convert]::ToString($val, 2).PadLeft(8, '0')
    if ($bin -match '01.*1') { throw "Non-contiguous subnet mask: $mask" }
    $prefix += ($bin.ToCharArray() | Where-Object { $_ -eq '1' }).Count
  }
  return $prefix
}

function Get-InterfaceAlias([string]$connectionName)
{
  $adapter = Get-NetAdapter -Name $connectionName -ErrorAction SilentlyContinue
  if ($adapter) { return $adapter.Name }

  $adapter = Get-NetAdapter | Where-Object { $_.Name -like "*$connectionName*" } | Select-Object -First 1
  if ($adapter) { return $adapter.Name }

  throw "Interface not found: $connectionName"
}

#endregion

#region ICS Functions

function Set-ICSSharing([object]$hnet, [object]$pubConn, [object]$priConn, [bool]$enable)
{
  $pubCfg = $hnet.INetSharingConfigurationForINetConnection($pubConn)
  $priCfg = $hnet.INetSharingConfigurationForINetConnection($priConn)

  # Always disable first
  if ($pubCfg.SharingEnabled) { $pubCfg.DisableSharing() | Out-Null }
  if ($priCfg.SharingEnabled) { $priCfg.DisableSharing() | Out-Null }

  if ($enable)
  {
    $pubCfg.EnableSharing(0) | Out-Null  # 0 = Public
    $priCfg.EnableSharing(1) | Out-Null  # 1 = Private
  }

  return @{
    Public  = $pubCfg.SharingEnabled
    Private = $priCfg.SharingEnabled
  }
}

function Wait-ForIcsIP([string]$alias, [int]$timeoutSec = 30)
{
  Write-Host "Waiting for ICS initialization..." -ForegroundColor Cyan

  $elapsed = 0
  $interval = 500
  while ($elapsed -lt ($timeoutSec * 1000))
  {
    $ip = Get-NetIPAddress -InterfaceAlias $alias -AddressFamily IPv4 -ErrorAction SilentlyContinue |
      Where-Object { $_.IPAddress -eq $script:ICS_DEFAULT_IP }

    if ($ip)
    {
      Write-Host "  ICS ready ($($script:ICS_DEFAULT_IP) assigned)" -ForegroundColor Green
      Start-Sleep -Seconds 2  # NAT/DHCP stabilization
      return $true
    }

    Start-Sleep -Milliseconds $interval
    $elapsed += $interval
  }

  Write-Warning "Timeout waiting for ICS default IP"
  return $false
}

function Set-PrivateIP([string]$connectionName, [string]$ipAddress, [string]$subnetMask, [string[]]$dnsServers)
{
  $alias = Get-InterfaceAlias $connectionName
  $prefix = Convert-SubnetMaskToPrefix $subnetMask

  # Wait for ICS to finish initialization
  if (-not (Wait-ForIcsIP $alias)) {
    Write-Warning "Proceeding anyway - results may be unstable"
  }

  # Add new IP first (avoid IP-less state)
  $existing = Get-NetIPAddress -InterfaceAlias $alias -AddressFamily IPv4 -IPAddress $ipAddress -ErrorAction SilentlyContinue
  if (-not $existing)
  {
    Write-Host "Adding IP: $ipAddress/$prefix" -ForegroundColor Green
    New-NetIPAddress -InterfaceAlias $alias -IPAddress $ipAddress -PrefixLength $prefix -ErrorAction Stop | Out-Null
  }

  Start-Sleep -Seconds 1

  # Remove ICS default IP only
  $icsIP = Get-NetIPAddress -InterfaceAlias $alias -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -eq $script:ICS_DEFAULT_IP }

  if ($icsIP)
  {
    Write-Host "Removing ICS default IP: $($script:ICS_DEFAULT_IP)" -ForegroundColor Yellow
    Remove-NetIPAddress -InterfaceAlias $alias -IPAddress $script:ICS_DEFAULT_IP -Confirm:$false -ErrorAction SilentlyContinue
  }

  # Set DNS if specified
  if ($dnsServers -and $dnsServers.Count -gt 0)
  {
    Write-Host "Setting DNS: $($dnsServers -join ', ')" -ForegroundColor Green
    Set-DnsClientServerAddress -InterfaceAlias $alias -ServerAddresses $dnsServers | Out-Null
  }

  Write-Host ""
  Write-Host "=== Final Configuration ===" -ForegroundColor Cyan
  Get-NetIPConfiguration -InterfaceAlias $alias | Format-List
}

#endregion

#region Main

Assert-Admin

if ($Mode -eq "Enable") { Ensure-ICSServiceRunning }

$hnet = New-HNetShare
$connections = @(Get-Connections $hnet)

if ($connections.Count -lt 2)
{
  throw "At least two network connections are required."
}

Show-Menu $connections

$pubIdx = Read-Index "Select Public (Internet) interface" $connections.Count
$priIdx = Read-Index "Select Private (shared) interface" $connections.Count

if ($pubIdx -eq $priIdx)
{
  throw "Public and Private must be different interfaces."
}

$pub = $connections[$pubIdx]
$pri = $connections[$priIdx]

Write-Host ""
Write-Host "Public:  $($pub.Name)"
Write-Host "Private: $($pri.Name)"
Write-Host ""

$result = Set-ICSSharing $hnet $pub._Conn $pri._Conn ($Mode -eq "Enable")
Write-Host "ICS $($Mode)d. Public=$($result.Public) Private=$($result.Private)"

# Configure Private IP if requested
if ($Mode -eq "Enable" -and $ConfigurePrivateIP)
{
  if (-not $PrivateIPv4Address -or -not $PrivateSubnetMask)
  {
    throw "-PrivateIPv4Address and -PrivateSubnetMask are required with -ConfigurePrivateIP"
  }

  Set-PrivateIP -connectionName $pri.Name `
    -ipAddress $PrivateIPv4Address `
    -subnetMask $PrivateSubnetMask `
    -dnsServers $PrivateDnsServers
}

#endregion
