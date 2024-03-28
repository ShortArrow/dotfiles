$list = @("keybindings.json", "settings.json")
foreach ($item in $list) {
  Remove-Item "$env:APPDATA/Code/User/$item" -Force
  New-Item -Type SymbolicLink -Path "$env:APPDATA/Code/User" -Name $item -Value "$env:USERPROFILE/Documents/GitHub/dotfiles/code/$item"
}

