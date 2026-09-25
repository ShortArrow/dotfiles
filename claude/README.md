# Claude Code

This directory holds `CLAUDE.md`, the statusline and the notify hook. The
symlinks are declared in [`dotfm.toml`](../dotfm.toml).

## Skills

Skills are **not** in this repository. They moved to
[ShortArrow/skills](https://github.com/ShortArrow/skills) and install as
marketplace plugins, so a new machine needs a command rather than a second
clone.

```
claude plugin marketplace add ShortArrow/skills
claude plugin install screenshot-skills@shortarrow-skills
claude plugin install writing-skills@shortarrow-skills
claude plugin install engineering-skills@shortarrow-skills
```

They were moved out because they are not configuration. `dotfm` declares
where a config file belongs on disk; a skill is an instruction an agent
reads, versioned and shared on its own terms.

## Other marketplaces

Third-party skill collections are added the same way rather than vendored
here — copying them would mean carrying their licences and their update
cadence.

```
claude plugin marketplace add anthropics/skills
```

The list of collections worth knowing about is kept with the skills, in
[ShortArrow/skills](https://github.com/ShortArrow/skills#other-marketplaces),
so there is one copy of it.

## Settings

`settings.json` is not linked — it accumulates per-machine permission
entries. [`settings.sample.json`](settings.sample.json) holds the keys worth
carrying to every machine, and `setup.ps1` merges them in: a key the sample
declares wins, a key it says nothing about is left alone, and `permissions`
is never touched. The file is backed up before it is rewritten, and an apply
that would change nothing says `noop`.

[`env.sample`](env.sample) does the same for the environment, but is copied
by hand — it carries a secret.

The sample declares that nothing this repository publishes carries an
attribution trailer or a session link, both by setting `attribution` and by
`PreToolUse` hooks that refuse a `git commit` or a `gh` command whose body
contains one. The setting alone was not enough: `attribution.sessionUrl`
only governs commits made from web and Remote Control sessions.

The hooks match on the body, not on the subcommand, so `gh pr list` and
`gh api` pass untouched while `issue`, `release` and `gist` are covered
without naming each one. A commit or a pull request title may still say
"claude" — only the trailer forms and the session URL are refused.

Both shells are covered, because this same file turns the PowerShell tool
on with `CLAUDE_CODE_USE_POWERSHELL_TOOL`. A guard on `Bash` alone leaves
`git commit` reachable through the other tool, which is the failure that
looks installed and is not.

Neither entry carries an `if`; both call
[`check-attribution.sh`](check-attribution.sh), which decides the command
shape itself. `if` takes a permission rule, and a rule naming a tool that
does not accept one would fail by never firing — silently, which is the one
outcome a guard may not have.

## The signing key expires

`gpg-agent.conf` caches the passphrase for eight hours, so once a day a
signed commit from a session fails with `gpg failed to sign the data`:
a tool call has no way to open pinentry. Left to prose, the session
tried the commit, read the failure, and asked the user to unlock the key
and report back. [`check-gpg-cache.sh`](check-gpg-cache.sh) asks the
agent first. `gpg-connect-agent 'keyinfo --list'` prints a cached flag
per keygrip, so the hook knows before the commit runs, and its deny
reason carries the one command that fixes it, to be typed in the prompt:

```
! echo test | "$(git config --get gpg.program)" --clearsign > /dev/null
```

The `!` runs it in the session, where pinentry can open, and the agent
caches the passphrase for the next eight hours. Two details are in the
command for a reason. `gpg.program` names the GnuPG that git calls;
in Git Bash on Windows both `gpg` and `gpg.exe` resolve to MSYS's
`/usr/bin/gpg`, which has its own home and its own agent, so an unlock
typed that way caches nothing git can use. And `> /dev/null` rather than
`> nul`: in Git Bash `nul` is a file, and the command would leave one in
the repository.

The hook takes the key from the repository's `user.signingkey` and the
agent from the directory of `gpg.program`, treats the primary key and
any signing-capable subkey as the set that has to be cached, and stays
silent for reads, pushes, `--no-gpg-sign`, repositories that do not
sign, and directories outside a repository. It runs on both shells, for
the same reason as the attribution guard.
[`check-gpg-cache.test.sh`](check-gpg-cache.test.sh) fakes the agent
with a script that reports the cache from an environment variable, so it
runs without a key and without touching the real agent.

Keeping the gate in a script is also what makes it testable. Run
[`check-attribution.test.sh`](check-attribution.test.sh): it pipes a
`tool_input` at the script and reads the verdict, over the trailer forms,
the bare session URL, a clean commit, dependabot's lowercase
`Co-authored-by:`, and the searches — `git log --grep`, `grep` — that carry
the pattern as a search term and have to keep working. That last case is not
hypothetical: the pattern was grepped for in this repository while the guard
was being written.
