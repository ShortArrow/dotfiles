# my markdown settings

## Linux

Installation of marksman.

```bash
sudo mkdir /usr/share/marksman/
sudo curl https://github.com/artempyanykh/marksman/releases/download/2022-06-23/marksman-linux \
  --output /usr/share/marksman/marksman-linux
sudo ln -s /usr/share/marksman/marksman-linux /usr/bin/marksman
which marksman # check which file is marksman
file /usr/bin/marksman # check symboliclink
```
