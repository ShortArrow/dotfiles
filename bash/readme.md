# my bash settings

## Usage

1. Make symboliclink.
  
  ```bash
  rm -rf ~/.bash_myplug
  ln -s $HOME/Documents/GitHub/dotfiles/bash/bash_myplug.sh ~/.bash_myplug # caution! Don't needs slash at last.
  file ~/.bash_myplug # check link
  ```
  
1. Write this at the end of `~/.bashrc`.
  
  ```bash
  source ~/.bash_myplug
  ```
  
1. For load the settings. Reopen bash, or run command as bellow in current bash terminal.
  
  ```bash
  source ~/.bashrc
  ```
  
## Dependencies

- [starship](https://starship.rs)
- [dotnet](https://docs.microsoft.com/ja-jp/dotnet/core/install/)

## LSP

```
npm i -g bash-language-server
```
