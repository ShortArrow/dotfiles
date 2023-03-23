---
title : 'JavaScript'
description: "my javascript setting"
summary: "javascript settings"
tags: ["docs"]
---

## Version Management

Use [fnm](https://github.com/Schniz/fnm) for node.js version management

## Library version management in Project

check npm doctor and enable yarn.

```bash
fnm use 16
npm doctor
corepack enable
```

## Install LSP

```bash
yarn global add diagnostic-languageserver
yarn global add eslint_d
yarn global add tsserver 
yarn global add tsc
```
