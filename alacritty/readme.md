# Aracritty

## Usage

Make SymbolicLink.

### Windows

```powershell
Remove-Item $env:Appdata/alacritty/alacritty -Force
New-Item -Type SymbolicLink -Path "$env:appdata/alacritty" -Name "alacritty.yml" -Value "$env:USERPROFILE/Documents/GitHub/dotfiles/alacritty/alacritty.yml"
```

### Linux

```bash
```

