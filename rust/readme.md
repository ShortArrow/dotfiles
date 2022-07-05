# my rust settings

## Version Control

Install [rustup](https://rustup.rs/)

## LSP

```bash
rustup +nightly component add rust-analyzer-preview
 sudo ln -s $HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer /usr/bin/rust-analyzer
```

## bashrc

```bash
export PATH=~/.npm-global/bin:$PATH
"$HOME/.cargo/env"
```
