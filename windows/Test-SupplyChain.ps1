#!pwsh

# Supply-chain guards on the tool installers.
#
# mise installs npm packages through aube, which refuses anything under a
# thousand weekly downloads, and holds back releases younger than
# minimum_release_age. Both guards are global: weakening one to admit a single
# package removes it for every package declared now and later, and does so
# silently — the guard is not overridden, it stops being consulted.
#
# The second check asks what an npm package actually asserts. A matching
# version number proves nothing, and a maintainer handle resembling a GitHub
# account is circumstantial. A SLSA provenance attestation is neither: it binds
# the published tarball to the repository and CI job that produced it. Packages
# without one are not thereby malicious — most are simply published by hand —
# but they cannot be verified, so adding one is a decision rather than a check.

$miseConfig = Join-Path $env:USERPROFILE '.config/mise/config.toml'

Write-Host ""
Write-Host "Checking supply-chain guards..." -ForegroundColor Cyan

function Show-SupplyChainResult([bool]$IsOK, [string]$Message)
{
  Write-Host "- [" -NoNewline
  Write-Host $($IsOK ? "OK" : "NG") -ForegroundColor $($IsOK ? "Green" : "Red") -NoNewline
  Write-Host "]: $Message"
}

if (-not (Test-Path -LiteralPath $miseConfig))
{
  Show-SupplyChainResult $false "mise config not found at $miseConfig"
  return
}

$configText = Get-Content -LiteralPath $miseConfig -Raw

$weakeners = @(
  @{ Pattern = 'npm\.package_manager\s*=\s*"npm"'; Says = 'npm.package_manager = "npm" bypasses aube''s download-count guard for every npm tool' },
  @{ Pattern = 'lowDownloadThreshold\s*=\s*0';     Says = 'lowDownloadThreshold = 0 disables the download-count guard' },
  @{ Pattern = 'minimum_release_age\s*=\s*"?0';    Says = 'minimum_release_age = 0 installs releases the moment they are published' }
)

$found = @($weakeners | Where-Object { $configText -match $_.Pattern })
if ($found.Count -eq 0)
{
  Show-SupplyChainResult $true "no guard is disabled in mise config"
} else
{
  Show-SupplyChainResult $false "$($found.Count) guard(s) disabled"
  $found | ForEach-Object { Write-Host "    $($_.Says)" -ForegroundColor Yellow }
}

# Provenance of the declared npm tools.
$npmTools = [regex]::Matches($configText, '(?m)^\s*"npm:([^"]+)"\s*=') |
  ForEach-Object { $_.Groups[1].Value }

if ($npmTools.Count -eq 0)
{
  return
}

$unattested = @()
foreach ($tool in $npmTools)
{
  try
  {
    $meta = Invoke-RestMethod "https://registry.npmjs.org/$tool" -TimeoutSec 15 -ErrorAction Stop
    $latest = $meta.'dist-tags'.latest
    if (-not $meta.versions.$latest.dist.attestations)
    {
      $unattested += $tool
    }
  } catch
  {
    $unattested += "$tool (registry lookup failed)"
  }
}

# Reported rather than failed. Publishing without an attestation is ordinary,
# not suspicious — it only means provenance cannot be checked mechanically, so
# adding such a package is a judgement someone has to make and own.
$attested = $npmTools.Count - $unattested.Count
Write-Host "- [" -NoNewline
Write-Host "i" -ForegroundColor Cyan -NoNewline
Write-Host "]: " -NoNewline
Write-Host "$attested of $($npmTools.Count) npm tool(s) publish a provenance attestation" -ForegroundColor DarkGray
$unattested | ForEach-Object { Write-Host "    unverifiable: $_" -ForegroundColor DarkGray }
