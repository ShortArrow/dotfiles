# Git

## Hooks

`setup.{ps1,sh}` points `core.hooksPath` at [`hooks/`](hooks/), globally, so
the guard covers every repository on the machine instead of the one it was
installed into.

| Hook | Refuses |
|---|---|
| `commit-msg` | a message carrying an attribution trailer or a session link |
| `pre-push` | commits already carrying one — pulled from elsewhere, or written before the hook existed |

`commit-msg` sees the finished message as a file, so `-m`, `-F`, `--amend`
and the editor all reach it. The `PreToolUse` guard in
[`../claude/`](../claude/) sees only a command line and therefore cannot see
`-F` or a message assembled at run time; that one refuses the common case
early, this one is the guarantee. Dependabot's lowercase `Co-authored-by:`
passes both — it credits a real author.

A global `core.hooksPath` replaces `.git/hooks` everywhere, so both hooks
call the repository's own version at the end if it has one, with the same
arguments and the same stdin.

`bash hooks/hooks.test.sh` exercises both, including a commit whose message
arrived through `-F`, and checks that the two guards return the same verdict
on the same messages. Neither hook survives `--no-verify`; nothing hooks can
do about that.

## Set default branch name

```bash
git config --global init.defaultBranch main
```

## GPG cofig

Windows

```powershell
git config --global gpg.program "C:\\Program Files (x86)\\GnuPG\\bin\\gpg.exe"
git config --global commit.gpgsign true
git config user.signingkey 7B66415DC7B803DD
#git config --global gpg.program "gpg.exe --pinentry-mode loopback"
```

WSL2

```bash
GPG_TTY=$(tty)
export GPG_TTY
sudo ln -s /mnt/c/Program\ Files\ \(x86\)/GnuPG/bin/gpg.exe /usr/local/bin/gpg
sudo ln -s gpg /usr/local/bin/gpg2
```

In the `~/.gnupg/gpg-agent.conf`<- maybe not need.

```bash
pinentry-program "/mnt/c/Program Files (x86)/Gpg4win/bin/pinentry.exe"
```

```powershell
pinentry-program "C:\\Program Files (x86)\\GnuPG\\bin\\pinentry-basic.exe"
```

## Github Docs

[Signing commit](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)
[Generating a new GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)
[Telling Git about your signing key](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key)
