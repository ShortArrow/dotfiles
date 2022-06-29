# my bash settings

## Usage

Clone repository.

```bash
mkdir $HOME/Documents/GitHub/
git clone https://github.com/ShortArrow/my-nvim-config.git $HOME/Documents/GitHub/my-nvim-config
cd $HOME/Documents/GitHub/my-nvim-config
rm -rf ~/.bash_myplug
ln -s $HOME/Documents/GitHub/my-nvim-config/bash/.bash_myplug ~/.bash_myplug # caution! Don't needs slash at last.
file ~/.bash_myplug # check link
```

Write this at the end of `~/.bashrc`.

```bash
source .bash_myplug
```

Reopen bash, or run command as bellow in current bash terminal.

```bash
source ~/.bashrc
```

