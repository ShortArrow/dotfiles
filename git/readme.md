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

## Signing

[`signing.ps1`](signing.ps1) — the dotfm tool `git-signing`, Windows-only —
wires commit, merge and tag signing to SSH keys held in the Bitwarden vault,
reached through the Windows OpenSSH agent pipe. It sets no global
`user.signingkey`: each repository declares its own identity, so a
repository that has not declared one refuses to commit instead of signing
with the wrong key. The allowed-signers list stays machine-local at
`~/.config/git/allowed_signers`, outside this public checkout.

It is separate from `setup.{ps1,sh}` so a machine without the vault still
gets the general config and the hooks. GPG remains installed only to
decrypt and verify pre-2026 GPG signatures.

## Github Docs

[Signing commit](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)
[Generating a new GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)
[Telling Git about your signing key](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key)
