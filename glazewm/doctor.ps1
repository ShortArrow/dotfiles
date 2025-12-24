#!pwsh

Get-ScheduledTask -TaskName "glazewm_task" |
Select-Object -ExpandProperty Actions |
Select-Object Execute, Arguments |
Format-List

schtasks.exe /query /tn glazewm_task /FO CSV /V |
ConvertFrom-Csv
