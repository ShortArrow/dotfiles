## Save

```bash
pacman -Qe > pacman/installed_packages.txt
```

## Install

```bash
sudo pacman -S --needed $(cat installed_packages.txt | awk '{print $1}')
```
