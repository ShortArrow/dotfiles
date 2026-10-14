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
. V:\github.com\ShortArrow\dotfiles\pwsh\src\pwsh_myplug.ps1
```

Dot-source the checkout path, not the `Documents\PowerShell\myplug` link
that dotfm creates: a shell reached over SSH runs under the Redirection
Trust mitigation inherited from sshd, which refuses to follow a symlink
owned by a non-elevated user, and the profile would fail on its first line.

read [script-scope-and-dot-sourcing](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts#script-scope-and-dot-sourcing)

## kana lock

With kana lock on, a field that turns the IME off, such as pinentry's
passphrase field, receives letters as half-width kana: `test` arrives as
`ｶｲﾄｶ`. The IME still shows half-width alphanumeric. A 101-key keyboard has
no kana key to clear it by hand.

The profile warns on start when kana lock is on. `Disable-KanaLock` turns it
off, and `Get-KanaLockState` reports it. The user32 calls are compiled once
into `~/.cache/pwsh-native`.

## sudo

Windows 11 ships `sudo.exe` in `System32`. Enable it in
**Settings > System > For developers**, or from an elevated prompt:

```powershell
sudo config --enable normal
sudo config              # report the current mode
```

The three modes differ in how the elevated process is attached:
`forceNewWindow` opens a separate console, `disableInput` runs inline but
refuses stdin, and `normal` runs inline with input. This machine is in
`disableInput`.

[sudo for Windows](https://learn.microsoft.com/en-us/windows/sudo/)
