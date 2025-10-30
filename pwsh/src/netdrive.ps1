#!pwsh
$target = Read-Host "PATH"
$user = Read-Host "User"
$creds = Get-Credential -UserName "$user"
$drive = Read-Host "Drive"

$password = $creds.GetNetworkCredential().Password
$username = $creds.UserName

if (Test-Path "${drive}:") {
        Write-Host "Already exists"
}
else {
        net use "${drive}:" $target /user:$username $password /persistent:yes
}

