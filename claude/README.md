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
claude plugin marketplace add nanaism/yomiyasu
claude plugin install yomiyasu@yomiyasu
```

The list of collections worth knowing about is kept with the skills, in
[ShortArrow/skills](https://github.com/ShortArrow/skills#other-marketplaces),
so there is one copy of it.

## Where a hook lives

A hook that turns a skill's rule into a check, and holds for anyone who
uses that skill, lives in
[ShortArrow/skills](https://github.com/ShortArrow/skills) and ships in the
same plugin as the skill. A hook that rests on one person's arrangements —
a command of their own, a particular machine or path, an employer's rules —
lives here, and so does every registration in `settings.json`. No hook is
kept in both places.

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
and report back. [`check-gpg-cache.sh`](check-gpg-cache.sh) tries
first: it signs a throwaway text with the repository's key and
`--pinentry-mode error`, which fails rather than prompts, so the hook
knows before the commit runs. The agent's per-keygrip cached flag is not
read; GnuPG 2.5 was seen signing without a prompt while the flag reported
the signing keygrip uncached. The deny reason sends the user to one
command, typed in the prompt:

```
! git unlock
```

The `!` runs it in the session, where pinentry can open, and the agent
caches the passphrase for the next eight hours. `git unlock` is an alias
for [`git/unlock.sh`](../git/unlock.sh), which a machine without the alias
can run directly. It takes the key from the repository's
`user.signingkey` and gpg from `gpg.program`, so it unlocks the key the
repository signs with, in the agent git uses; in Git Bash on Windows a
bare `gpg` or `gpg.exe` is MSYS's `/usr/bin/gpg`, with its own home and
agent, and an unlock typed with it caches nothing git can use. The reason
names no gpg line for the user to type, and
[`check-gpg-clearsign.pl`](check-gpg-clearsign.pl) refuses the agent
running one.

The hook takes the key from the repository's `user.signingkey` and gpg
from `gpg.program`, and stays silent for reads, pushes, `--no-gpg-sign`,
repositories that do not sign, a key missing from the keyring, and
directories outside a repository. It runs on both shells, for the same
reason as the attribution guard.
[`check-gpg-cache.test.sh`](check-gpg-cache.test.sh) fakes gpg with a
script that signs only while an environment variable is set and logs its
arguments, so it runs without a key, without touching the real agent,
and checks that the trial names the signing key.

Keeping the gate in a script is also what makes it testable. Run
[`check-attribution.test.sh`](check-attribution.test.sh): it pipes a
`tool_input` at the script and reads the verdict, over the trailer forms,
the bare session URL, a clean commit, dependabot's lowercase
`Co-authored-by:`, and the searches — `git log --grep`, `grep` — that carry
the pattern as a search term and have to keep working. That last case is not
hypothetical: the pattern was grepped for in this repository while the guard
was being written.

## The passphrase is the user's to type

The signing passphrase is cached by the user typing `! git unlock`
([`git/unlock.sh`](../git/unlock.sh)), which takes the key and gpg from the
repository's own config. [`check-gpg-clearsign.pl`](check-gpg-clearsign.pl)
refuses a shell command that runs gpg with `--clearsign` or `--clear-sign`
— `gpg`, `gpg2`, `gpg.exe` by name or path, the `gpg.program` that
`git config` prints, or a variable named `gpg` — and its reason says the
user enters the passphrase with `! git unlock`, and the agent does not
type it. `git unlock` itself passes: its script uses `--clearsign`, but
the line the agent runs does not. The line is split into segments outside
quotes and each is judged by its leading command, so a commit message, a
`grep` pattern or an `echo` that mentions `--clearsign` passes. It runs on
both shells, and [`check-gpg-clearsign.test.sh`](check-gpg-clearsign.test.sh)
holds the shapes it refuses and lets through, and the reason's wording.

## Scheduled tasks on an ssh host

A scheduled task on a remote Windows host is registered by a script sent
with `scp`, and ssh runs only the line that starts it. The check that
refuses a task command on the ssh line is `check-ssh-task-registration.sh`,
which ships with the `engineering-skills` plugin of
[ShortArrow/skills](https://github.com/ShortArrow/skills), so it is not
kept here.

## Commands refused, confirmed or logged where the policy guard is enabled

[`check-command-policy.pl`](check-command-policy.pl) runs only on the
machines that enable it. It reaches a machine through its own dotfm tool,
`claude-command-policy`, enabled per machine, and it is registered by hand
in that machine's `settings.json` for both shells; `settings.sample.json`
does not carry it, because the sample travels to every machine.

| Level | Decision | Commands |
|---|---|---|
| ERROR | deny | `-ExecutionPolicy Bypass`, `Set-ExecutionPolicy Bypass`, on this machine or on an `ssh` line; `schtasks /create`, `/change`, `/delete`; `Register-ScheduledTask`; `powershell` or `pwsh` with `-EncodedCommand` (`-enc`, `-ec`, `-e`); `sc create`, `New-Service`; `wmic process call create`, `Invoke-CimMethod` or `Invoke-WmiMethod` on `Win32_Process` `Create` |
| WARN | ask | `Invoke-Command`, `Enter-PSSession`, `New-PSSession`; `psexec`; `Start-Process -Verb RunAs`; a write to `CurrentVersion\Run` or `RunOnce`; a write to `Start Menu\Programs\Startup` |
| INFO | log, allow | a command run over `ssh` that names `powershell`, `schtasks`, `wmic` or `sc create` |

Every hit, at every level, appends one line to
`~/.claude/logs/command-policy.log` (time, level, labels, command), or to
`$CLAUDE_COMMAND_POLICY_LOG` when that is set.

A rule fires on the command a segment runs. The line is split at `;`,
`&`, `|`, parentheses, braces and newlines that stand outside quotes, and
each segment is judged by its leading command, looking through `$x =`,
`&`, `sudo`, `cmd /c` and `Start-Process`. A quoted string, a commit
message, a `grep` pattern or an `echo` that only mentions a word matches
nothing. A here-document body counts as commands only when it feeds a
shell. Reads stay open: `schtasks /query`, `reg query` on the Run key, a
listing of the Startup folder.

A segment led by `ssh` runs on another machine, so it is only logged here,
except `-ExecutionPolicy Bypass`, which is refused on the `ssh` line too;
the rest of what it may do there is that host's policy and the plugin's
ssh task check above. The hook reads the command line and nothing else: the body of a
script sent with `scp`, or of any `.ps1` started with `-File`, is not seen.

A script sent with `scp` carries no `Zone.Identifier`, so it runs under
`RemoteSigned` and never needs `Bypass`; the refusal says so, and says to
read `Get-ExecutionPolicy -List` on the host first. Start it in the form
its host's policy calls for:

- A host whose `LocalMachine` policy is `RemoteSigned` takes the script as
  is: `ssh <host> powershell -NoProfile -File <script>`. Tried 2026-11-20
  on Windows PowerShell 5.1: the script ran with no policy on the line, and
  the file arrived with no `Zone.Identifier` stream.
- A host whose every scope is `Undefined` falls back to Windows' default,
  `Restricted`, so the policy is named on the line:
  `ssh <host> powershell -NoProfile -ExecutionPolicy RemoteSigned -File
  <script>`. Tried 2026-11-20 on Windows PowerShell 5.1: the script ran,
  and the file arrived with no `Zone.Identifier` stream.

[`check-command-policy.test.sh`](check-command-policy.test.sh) holds one
corpus per level and the mentions that must pass.

## A second opinion on shell commands

[`judge-command.sh`](judge-command.sh) sends each shell command to a
SystemOne model served by a local Ollama (`POST <base>/v1/systemone`)
with two yes/no questions: is it hard to undo, and does it reach
outside this machine. It records both probabilities, and it can turn a
high one into a confirmation. That is all it may do.

- **Only `ask`, never `allow` or `deny`.** A probability says how
  concentrated the model's answer is, not whether the answer is right.
  Commands that must never run are refused by deterministic hooks, which
  the model sits beside and never replaces.
- **Off unless the machine opts in.** The endpoint is one machine's
  arrangement, and the sample travels to every machine. The hook reads
  `~/.claude/systemone.env` (or the environment) and does nothing without
  `SYSTEMONE_BASE_URL` and `SYSTEMONE_MODEL`, so a machine that cannot reach the model sends nothing
  and waits for nothing. The `env` block of the sample is not the place:
  the merge replaces it whole.
- **It asks the person, not the agent.** A judge that stops the agent and
  makes it redo work changes an open-ended loop in ways no log explains;
  a confirmation leaves the agent's plan alone and puts one question in
  front of the user. Whether that question earns its place is decided by
  the log: a command the model rates high that Claude Code's own
  permission prompt already stops gains nothing from a second prompt.
- **Recording first.** The default mode only appends to
  `~/.claude/systemone-log.jsonl`. Ask mode needs a cutoff as well, and there
  is no default one: a cutoff is read off this machine's own log, not
  borrowed from someone else's examples.
- **Fails open.** A timeout (1.5 s for the request, 3 s for the hook), an
  unreachable host, or a reply that is not the API's all end in silence.

A machine that serves the model with Ollama, for example:

```
SYSTEMONE_BASE_URL=http://<host>:11434
SYSTEMONE_MODEL=tev1:4b
SYSTEMONE_KEEP_ALIVE=-1
# SYSTEMONE_MODE=ask
# SYSTEMONE_ASK_AT=<from the log>
```

`SYSTEMONE_KEEP_ALIVE` keeps the model loaded, since a reload costs seconds
where an answer costs tenths. The hook sends no credential: the endpoint
is an Ollama on a machine of this user's, not a hosted service. What the model cannot judge is what the command text does not
show: a script or a container that posts somewhere looks harmless. The
model reads the words, and the deterministic hooks stay the floor.
[`judge-command.test.sh`](judge-command.test.sh) puts a fake `curl` on
`PATH`, so it runs without a model.
