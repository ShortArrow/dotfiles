# my powershell config

## check profile

```powershell
echo $PROFILE
```

[about_Profiles](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles)

### Windows

Make SymbolicLink. Please run `setup.ps1` as Administrator priviledges.

```powershell
cd dotfiles/pwsh
./setup.ps1
```

## setup execution policy

```powershell
Get-ExecutionPolicy -List
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Get-ExecutionPolicy -List
```

[about_Execution_Policies](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies)

## add to profile

```powershell
. $PROFILE/myplug/pwsh_myplug.ps1
```

read [script-scope-and-dot-sourcing](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts#script-scope-and-dot-sourcing)

## sudo

```powershell
go install github.com/mattn/sudo@latest
```

[mattn/sudo](https://github.com/mattn/sudo)
