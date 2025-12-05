param(
  [string]
  $Source,
  [string]
  $Destination
)

if(!(Test-Path $Source))
{
  Write-Host "Unexists path" -ForegroundColor Red
  exit
}

$FullPath = (Resolve-Path $Source)

if($Destination -eq "")
{
  $NewDirectory = (Split-Path $FullPath -LeafBase)
  $BaseDirectory = (Split-Path $FullPath -Parent)
  $Destination = (Join-Path -Path $BaseDirectory -ChildPath $NewDirectory)
}

Write-Host "Source: $Source"
Write-Host "Destination: $Destination"

7z x -mcp=932 -o"$Destination" $Source
