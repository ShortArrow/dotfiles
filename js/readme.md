---
title : 'JavaScript'
description: "my javascript setting"
summary: "javascript settings"
tags: ["docs"]
---

## Version Management

[mise](https://mise.jdx.dev/) owns the runtimes. They are declared in
[`mise/src/config.toml`](../mise/src/config.toml), so a machine gets them
from `mise install` rather than a per-language installer.

```toml
node = "latest"
pnpm = "latest"
bun  = "latest"
```

`npm` and `yarn` ship with node. Use `corepack` when a project needs a
pinned package-manager version.

## npm client config

`js/npmrc` is symlinked to `~/.npmrc` on Windows and sets:

```ini
script-shell=pwsh
```

npm runs lifecycle scripts through `cmd.exe` by default, and cmd expands an
environment variable to at most 8191 characters. A mise shim prepends the
install directory of every managed tool, which can push PATH past that
limit — and past it cmd resolves nothing from PATH, so a run-script fails
with `'tsc' is not recognized` for a binary that is plainly installed.
PowerShell has no equivalent limit.

The link is Windows-only: `pwsh` is not guaranteed to exist elsewhere, and
the limit being worked around is a cmd.exe property. `windows/doctor.ps1`
reports how much headroom the PATH still has.

## In Docker

### pnpm in Docker

```bash
corepack enable && corepack prepare pnpm@latest --activate
```

### yarn in Docker

```bash
corepack enable
```

## Library version management in Project

```bash
npm doctor
```

## Install LSP

```bash
:MasonInstall typescript-language-server
:MasonInstall eslint-lsp
:MasonInstall eslintd
:MasonInstall biome
```
