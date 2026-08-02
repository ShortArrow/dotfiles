---
title: "A config that has to be generated"
description: "GlazeWM reads one file and supports no includes, so keeping part of it out of a public repository means building the file before the window manager sees it."
summary: "Splitting a config that cannot be split, and the two failures the splice has to refuse."
---

The GlazeWM `window_rules` ignore list names every application that
should stay unmanaged. On [the machine](/machine/) that is eleven processes, several
of which map straight to repositories of the same name — so the list said
which projects exist as much as which windows to skip. In a public
repository that is more than it needs to say.

## No seam to use

GlazeWM reads a single file. `user_config.rs` deserialises one string;
there is no `include:`, and rules cannot be scoped per workspace. The
config is composed before the window manager looks at it or not at all.

So `config.yaml` keeps a marker where the machine-specific entries go:

```yaml
      # Machine-specific ignores are spliced in here from ignore-local.txt,
      # which is untracked.
      # LOCAL-IGNORES
```

`ignore-local.txt` holds process names, one per line, and is gitignored.
`Merge-GlazewmConfig.ps1` generates the entries and writes the result to
`~/.glzr/glazewm/config.yaml`.

The local file holds **data, not YAML**. Generating the
`- window_process: { equals: '...' }` line from a bare name means the
untracked file cannot drift out of syntax with the tracked one.

## Reload has to run the merge

The keybinding does not reload. It runs the merge, and the merge issues
the reload once the file is written:

```yaml
  - commands: ['shell-exec pwsh -NoProfile -WindowStyle Hidden -File %USERPROFILE%/.glzr/glazewm/Merge-GlazewmConfig.ps1']
    bindings: ['alt+shift+r']
```

`shell-exec` returns as soon as the process starts, so a binding that ran
both would reload against whatever was on disk at that moment — usually
the previous build.

## Two failures it refuses

**The destination stops being a symlink.** It was one, into the
repository. Writing the generated result through it would commit the
machine-specific list back into git, which is the whole thing being
avoided. The script removes the link on first run.

**A missing marker is fatal.** Without the check, a base file with no
marker produces a config that is valid, loads cleanly, and silently
ignores nothing — the local rules just vanish. So:

```
Marker '# LOCAL-IGNORES' is missing from …
Nothing would be spliced, so refusing to write a config that silently
drops the local ignores.
```

That check earned itself immediately. The script is symlinked next to the
generated config so the keybinding can reach it by a stable path, and
`$PSScriptRoot` resolves to the link's own directory — which is where the
*output* lives. Reading the base from there would have fed the generated
file back into itself. The error appeared on the first run through the
link, and the script now follows its own symlink to find the source.
