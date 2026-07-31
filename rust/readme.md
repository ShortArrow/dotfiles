---
title : 'Rust'
summary: "rust config"
tags: ["docs"]
---
# my rust settings

## Version Control

[mise](https://mise.jdx.dev/) owns the toolchain — `rust = "latest"` in
[`mise/src/config.toml`](../mise/src/config.toml). It drives `rustup`
underneath, so `rustup toolchain` still works for adding targets and
nightly; there is no separate rustup install step.

`cargo install` writes to `~/.cargo/bin`, which stays on PATH ahead of the
winget shim directory. That ordering is deliberate: when developing a tool
that is also distributed as a package, the locally built binary should win.
The rule is declared in
[`windows/path-order.toml`](../windows/path-order.toml).

## LSP

```bash
:MasonInstall rust-analyzer
:MasonInstall rust-fmt
```

## Embedded

The ESP toolchains are installed by `espup` rather than mise, and live under
`~/.rustup/toolchains/esp`. Both of their bin directories are declared in
[`windows/PATH.txt`](../windows/PATH.txt).
