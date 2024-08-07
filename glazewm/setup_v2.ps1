$list = @("config.yaml")
foreach ($item in $list) {
  Remove-Item "$env:USERPROFILE/.glaze-wm/$item" -Force
  New-Item -Type SymbolicLink -Path "$env:USERPROFILE/.glaze-wm/" -Name $item -Value "$env:USERPROFILE/Documents/GitHub/dotfiles/glazewm/$item"
}

