#!pwsh
. "$PSScriptRoot/../lib/_lib.ps1"
Set-DotfileLinks -ToolName 'pwsh'

# $PROFILE bootstrapping is intentionally NOT automated:
# overwriting $PROFILE without consent is destructive. Run manually
# (once, after this script or `dotfm apply`) the line below in
# PowerShell:
#
#   Add-Content -LiteralPath $PROFILE -Value '. $HOME/Documents/PowerShell/myplug/pwsh_myplug.ps1'
#
# See pwsh/readme.md for details.
Write-DotfileInfo 'pwsh: edit $PROFILE manually if not already done. Run once:'
Write-DotfileInfo '  Add-Content -LiteralPath $PROFILE -Value ''. $HOME/Documents/PowerShell/myplug/pwsh_myplug.ps1'''
