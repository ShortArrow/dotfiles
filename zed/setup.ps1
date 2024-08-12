$list = @(
  "keymap.json",  
  "settings.json"
)

foreach ($item in $list)
{
  Remove-Item "$env:USERPROFILE/Appdata/Roaming/Zed/$item" -Force
  New-Item -Type SymbolicLink `
    -Path "$env:USERPROFILE/Appdata/Roaming/Zed/" `
    -Name $item `
    -Value "$env:USERPROFILE/Documents/GitHub/dotfiles/zed/src/$item"
}

