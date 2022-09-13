# my powershell config

## check profile

```powershell
echo $PROFILE
```

[about_Profiles](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles)

# Windows

Make SymbolicLink.

```powershell
$ProfileDir=(Split-Path $PROFILE -Parent)
Remove-Item (Resolve-Path $ProfileDir/pwsh_myplug.ps1) -Force
New-Item -Type SymbolicLink -Path "$ProfileDir" -Name "pwsh_myplug.ps1" -Value "$env:USERPROFILE/Documents/GitHub/dotfiles/pwsh_myplug.ps1"
Get-ChildItem -Path $env:LOCALAPPDATA -Force -ErrorAction 'silentlycontinue' |
Where-Object { $_.Attributes -match "ReparsePoint" -and $_.Name -match "nvim"}
```

## setup execution policy

```powershell
Get-ExecutionPolicy -List
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Get-ExecutionPolicy -List 
```

[about_Execution_Policies](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies)

## add to profile

```
. $PROFILE/pwsh_myplug.ps1
```

read [script-scope-and-dot-sourcing](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts#script-scope-and-dot-sourcing)

## sudo

```
go install github.com/mattn/sudo@latest
```

[mattn/sudo](https://github.com/mattn/sudo)
