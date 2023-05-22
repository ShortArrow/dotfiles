$configpath = "$env:Appdata/alacritty"
if(Test-Path "$configpath")
{
  Remove-Item "$configpath" -Recurse -Force
}
New-Item -Type SymbolicLink -Path "$env:Appdata" -Name "alacritty" -Value "$env:USERPROFILE/Documents/GitHub/dotfiles/alacritty"
