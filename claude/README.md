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

The sample declares that commits leave no attribution trailer, both by
setting `attribution` and by a `PreToolUse` hook that refuses a `git commit`
carrying one. The setting alone was not enough: `attribution.sessionUrl`
only governs commits made from web and Remote Control sessions.
