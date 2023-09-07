if (Test-Path "$env:APPDATA/lazygit/config.yml"){
  Remove-Item "$env:APPDATA/lazygit/config.yml"
}
New-Item -ItemType SymbolicLink -Path "$env:APPDATA\lazygit\config.yml" -Value "$env:USERPROFILE/Documents/GitHub/dotfiles/lazygit/config.yaml"
