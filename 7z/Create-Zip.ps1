param(
  [string]
  $Destination=".",
  [string]
  $Source
)

if(!(Test-Path $Source))
{
  Write-Host "Unexists path" -ForegroundColor Red
  exit
}

$7zpass = (New-Password)

Write-Host $7zpass

$ArchiveName = "$(Get-Date -Format 'yyMMddHHmmss').zip"

$Destination = (Join-Path -Path $Destination -ChildPath $ArchiveName)

Write-Host "Source: ${Source}"
Write-Host "Destination: ${Destination}"

7z a -tzip -mcp=932 -p"$7zpass" $Destination $Source
