$list = @("config.yaml", "script.js")
foreach ($item in $list) {
  Remove-Item "$env:USERPROFILE/.glzr/zebar/$item" -Force
  New-Item -Type SymbolicLink -Path "$env:USERPROFILE/.glzr/zebar/" -Name $item -Value "$env:USERPROFILE/Documents/GitHub/dotfiles/zebar/$item"
}

