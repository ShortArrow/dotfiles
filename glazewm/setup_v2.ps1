$list = @("config.yaml")
foreach ($item in $list) {
  Remove-Item "$env:USERPROFILE/.glzr/glazewm/$item" -Force
  New-Item -Type SymbolicLink -Path "$env:USERPROFILE/.glzr/glazewm/" -Name $item -Value "$env:USERPROFILE/Documents/GitHub/dotfiles/glazewm/$item"
}

