---
title: "PHP"
description: "PHP settings"
summary: "PHP settings"
tags: ["docs"]
---

# my php config

## Install LSP

```vim
:MasonInstall intelephense
```

## Install php

### Install php in Debian

```bash
sudo apt update && sudo apt -y upgrade
sudo apt -y install php php-common
php -v
sudo apt -y install php-cli php-fpm php-json \
php-pdo php-mysql php-zip php-gd  php-mbstring php-curl php-xml php-pear php-bcmath
```

## Install composer

The installer is rebuilt on every Composer release, so its SHA-384
changes with it. Upstream publishes the current one at
`https://composer.github.io/installer.sig` — fetch the hash rather than
pinning it, or the check reports `Installer corrupt` for a perfectly
good download.

```bash
EXPECTED="$(curl -fsSL https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '$EXPECTED') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); exit(1); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer
```

Fetching the signature over the same TLS connection is weaker than a
hash committed here, but a stale committed hash fails closed on every
release and gets skipped in practice. Pin it if a specific Composer
version matters.
