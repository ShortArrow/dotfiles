# Git

## Set default branch name

```bash
git config --global init.defaultBranch main
```

## GPG cofig

Windows

```powershell
git config --global gpg.program "C:\\Program Files (x86)\\GnuPG\\bin\\gpg.exe"
git config user.signingkey=7B66415DC7B803DD
git config commit.gpgsign true
git config --global gpg.program "gpg.exe --pinentry-mode loopback"
```

WSL2

```bash
GPG_TTY=$(tty)
export GPG_TTY
sudo ln -s /mnt/c/Program\ Files\ \(x86\)/GnuPG/bin/gpg.exe /usr/local/bin/gpg
sudo ln -s gpg /usr/local/bin/gpg2
```

In the `~/.gnupg/gpg-agent.conf`

```bash
# pinentry
pinentry-program /mnt/c/Program Files (x86)/Gpg4win/bin/pinentry.exe
```

```powershell
pinentry-program "C:\\Program Files (x86)\\GnuPG\\bin\\pinentry-basic.exe"
```

## Github Docs

[Signing commit](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)
[Generating a new GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)
[Telling Git about your signing key](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key)
