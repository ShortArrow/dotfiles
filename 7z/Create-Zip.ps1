param(
  [string]
  $Destination=".",
  [string]
  $Source,
  [switch]
  $NoPassword
)

if(!(Test-Path $Source))
{
  Write-Host "Unexists path" -ForegroundColor Red
  exit
}

$ArchiveName = "$(Get-Date -Format 'yyyyMMddHHmmss').zip"

$Destination = (Join-Path -Path $Destination -ChildPath $ArchiveName)

Write-Host "Source: ${Source}"
Write-Host "Destination: ${Destination}"

if ($NoPassword)
{
  7z a -tzip -mcp=932 $Destination $Source
} else
{
  $7zpass = (New-Password)
  Write-Host $7zpass
  7z a -tzip -mcp=932 -p"$7zpass" $Destination $Source
}
