# my bash settings

## Usage

Clone repository and make symboliclink.

```bash
mkdir $HOME/Documents/GitHub/
git clone https://github.com/ShortArrow/dotfiles.git $HOME/Documents/GitHub/dotfiles
cd $HOME/Documents/GitHub/dotfiles
rm -rf ~/.bash_myplug
ln -s $HOME/Documents/GitHub/dotfiles/bash/bash_myplug.sh ~/.bash_myplug # caution! Don't needs slash at last.
file ~/.bash_myplug # check link
```

Write this at the end of `~/.bashrc`.

```bash
source ~/.bash_myplug
```

For load the settings. Reopen bash, or run command as bellow in current bash terminal.

```bash
source ~/.bashrc
```

## Dependencies

- [starship](starship.rs)
- [dotnet](https://docs.microsoft.com/ja-jp/dotnet/core/install/)

## LSP

```
npm i -g bash-language-server
```
