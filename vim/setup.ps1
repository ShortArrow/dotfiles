#! pwsh

Remove-Item -Force $env:USERPROFILE/.vimrc

New-Item -Type SymbolicLink `
  -Path $env:USERPROFILE `
  -Name ".vimrc" `
  -Value "$env:USERPROFILE/Documents/GitHub/dotfiles/vim/.vimrc"
