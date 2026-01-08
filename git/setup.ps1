#!pwsh

## default branch
git config --global init.defaultBranch main

## github copilot
$configDirctory = "$env:USERPROFILE/.config/git/"

if(!(Test-Path $configDirctory))
{
  mkdir -p $configDirctory
}

"[commit]`n  verbose = true`n" > "$configDirctory/config"

"COMMIT_EDITMSG filetype=gitcommit`n" > "$configDirctory/attributes"

## delta

git config --global core.pager "delta"
git config --global interactive.diffFileter "delta --color-only"
git config delta.navigate true
git config merge.conflictStyle zdiff3
