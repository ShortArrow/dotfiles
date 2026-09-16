---
title: "Generating the GlazeWM config from a tracked base and an untracked list"
description: "GlazeWM reads a single file and has no include directive, so the part of the configuration that should stay out of a public repository has to be merged in before the window manager reads it. This note describes the marker, the merge script, and the two conditions under which the script refuses to write."
summary: "How a configuration file that cannot be split is still kept partly private, and the two failures the merge script refuses."
---

GlazeWM's `window_rules` section contains an ignore list: the applications
that the window manager should leave alone. On [this machine](/machine/)
that list has eleven process names, and several of them are the names of
projects I work on, because the process is named after its repository. In a
public repository, the list would therefore also announce which projects
exist. That is more than the configuration needs to reveal.

## Why the file has to be generated

GlazeWM reads exactly one file. Its `user_config.rs` deserialises a single
string; there is no `include:` directive, and rules cannot be attached to a
workspace. So the only way to keep part of the file private is to assemble
the whole file before GlazeWM reads it.

The tracked `config.yaml` marks the place where the private entries go:

```yaml
      # Machine-specific ignores are spliced in here from ignore-local.txt,
      # which is untracked.
      # LOCAL-IGNORES
```

The private entries live in `ignore-local.txt`, which is gitignored and
contains one process name per line. `Merge-GlazewmConfig.ps1` reads the
tracked file, replaces the marker with one generated
`- window_process: { equals: '...' }` line per name, and writes the result to
`~/.glzr/glazewm/config.yaml`, which is the file GlazeWM reads.

The local file holds plain names rather than YAML on purpose. Because the
script generates the YAML, the untracked file cannot fall out of sync with
the syntax used in the tracked one.

## The reload keybinding runs the merge

The `alt+shift+r` binding does not reload the configuration directly. It
runs the merge script, and the script issues the reload after it has
written the file:

```yaml
  - commands: ['shell-exec pwsh -NoProfile -WindowStyle Hidden -File %USERPROFILE%/.glzr/glazewm/Merge-GlazewmConfig.ps1']
    bindings: ['alt+shift+r']
```

The reason is that `shell-exec` returns as soon as the process has started.
A binding that listed the merge and then a reload would reload whatever
was on disk at that moment, which is usually the previous merge result.

## Two situations in which the script refuses to write

The destination must not be a symlink into the repository. It was one,
created by dotfm, and writing the generated file through it would have put
the private list into the tracked file, which is exactly what the whole
arrangement avoids. The script removes that link the first time it runs.

The marker must be present. Without this check, a base file that has lost
its marker would produce a configuration that is valid YAML, loads without
complaint, and simply does not contain the local rules. The script stops
with this message instead:

```
Marker '# LOCAL-IGNORES' is missing from …
Nothing would be spliced, so refusing to write a config that silently
drops the local ignores.
```

One more detail in the same area: the script is symlinked next to the
generated file so that the keybinding can refer to it by a stable path.
Inside the script, `$PSScriptRoot` is the directory of that link, which is
the output directory, so reading the base file relative to it would read
the previously generated file and feed it back into the merge. That is how
the missing-marker error first appeared. The script now follows its own
symlink to find the tracked base file in the repository.
