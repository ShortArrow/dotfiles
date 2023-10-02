---
title : 'JavaScript'
description: "my javascript setting"
summary: "javascript settings"
tags: ["docs"]
---

## Version Management

Use [volta](https://volta.sh/).

```bash
curl https://get.volta.sh | bash
```

### node

```bash
volta install node@20
```

### yarn

```bash
volta install node@20
```

### npm

```bash
volta install npm
```

### pnpm

```bash
volta install pnpm
```

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
