---
title : 'Rust'
summary: "rust config"
tags: ["docs"]
---
# my rust settings

## Version Control

On Windows, [mise](https://mise.jdx.dev/) owns the toolchain —
`rust = "latest"` in [`mise/src/config.toml`](../mise/src/config.toml).
It drives `rustup` underneath, so `rustup toolchain` still works for
adding targets and nightly; there is no separate rustup install step.

The Arch machine installs `rustup` from pacman instead and does not run
mise. Either way `rustup` is the interface; only who installs it differs.

`cargo install` writes to `~/.cargo/bin`, which stays on PATH ahead of the
winget shim directory. That ordering is deliberate: when developing a tool
that is also distributed as a package, the locally built binary should win.
The rule is declared in
[`windows/path-order.toml`](../windows/path-order.toml).

## LSP

```bash
:MasonInstall rust-analyzer
```

`rustfmt` is not a Mason package — it ships with the rustup toolchain and
`rust-analyzer` calls it directly.

## Embedded

The ESP toolchains are installed by `espup` rather than mise, and live under
`~/.rustup/toolchains/esp`. Both of their bin directories are declared in
[`windows/PATH.txt`](../windows/PATH.txt).
