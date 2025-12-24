Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name LongPathsEnabled
Get-ItemProperty -Path "HKCU:\Environment" -Name Path
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Environment" -Name Path