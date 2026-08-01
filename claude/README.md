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

- [anthropics/skills](https://github.com/anthropics/skills)
- [openai/skills](https://github.com/openai/skills)
- [github/awesome-copilot](https://github.com/github/awesome-copilot/tree/main/skills)
- [microsoftDocs/skills](https://github.com/MicrosoftDocs/Agent-Skills/tree/main/skills)
- [cloudflare/skills](https://github.com/cloudflare/skills)
- [android/skills](https://github.com/android/skills)

## Settings

`settings.json` is not linked — it accumulates per-machine permission
entries. [`settings.sample.json`](settings.sample.json) records the parts
worth carrying to a new machine, and [`env.sample`](env.sample) does the
same for the environment.
