---
summary: "tmux config"
tags: ["docs"]
---

# my tmux config

<!--toc:start-->

- [my tmux config](#my-tmux-config)
  - [Usage](#usage)
  - [Reload config](#reload-config)
  - [Dependencies](#dependencies)
  <!--toc:end-->

## Usage

1. Clone this repository.
1. Create `.tmux` folder in your home directory: `mkdir ~/.tmux`.
1. Make symbolic link.

```bash
rm -rf ~/.tmux_myplug
# caution! Don't needs slash at last of directory name
ln -s $HOME/Documents/GitHub/dotfiles/tmux/tmux_myplug.sh ~/.tmux_myplug
file ~/.tmux_myplug # check link
```

1. Install iceberg-dark

To download, run the following command:

```bash
wget -O $HOME/.tmux/iceberg_minimal_with_win_index.tmux.conf \
https://raw.githubusercontent.com/ShortArrow/iceberg-dark/master/.tmux/iceberg_minimal_with_win_index.tmux.conf
```

1. Add source commmand

Write this at the end of `~/.tmux.conf`.

```bash
source ~/.tmux_myplug
```

For load the settings, restart tmux session,
or run command as bellow in current tmux session after `<C-b>:`.

```bash
source ~/.tmux.conf
```

## Reload config

Way reload `tmux_myplug.sh` on keep tmux is alive.

```bash
source ~/.tmux.conf
```

## Dependencies

- [iceberg fork by ShortArrow](https://github.com/ShortArrow/iceberg-dark)
