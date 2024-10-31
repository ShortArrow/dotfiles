# GlazeWM

## How to install

```
winget install glazewm
./glazewm/setup.ps1
```

## Launch on login

Add taskscheduler action


```text
%LocalAppData%\Microsoft\WinGet\Links\glazewm.exe
```

```text
pwsh
-c "$PSStyle.OutputRendering='Ansi'; Start-Process -NoNewWindow 'C:\Users\who\Documents\GitHub\glazewm\target\release\glazewm.exe' -ArgumentList 'start'; pause;"
```
