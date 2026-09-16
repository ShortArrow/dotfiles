---
title: "GlazeWM の設定を、追跡する土台と追跡しない一覧から生成する"
description: "GlazeWM は 1 つのファイルしか読まず include もないので、公開リポジトリに置きたくない部分は、ウィンドウマネージャが読む前にファイルへ合成しておく必要があります。目印のコメント、合成スクリプト、スクリプトが書き込みを拒否する 2 つの条件について書きます。"
summary: "分割できない設定ファイルの一部を非公開に保つ方法と、合成スクリプトが拒否する 2 つの失敗。"
---

GlazeWM の `window_rules` には ignore の一覧があり、ウィンドウマネージャに管理
させないアプリケーションを並べます。[このマシン](/ja/machine/)ではプロセス名が
11 個あり、そのうちいくつかは自分が作業しているプロジェクトの名前と同じです。
プロセス名がリポジトリ名から付いているためです。公開リポジトリに置くと、この
一覧は「どのプロジェクトがあるか」まで知らせてしまいます。設定として明かす必要の
ない情報です。

## 生成しなければならない理由

GlazeWM が読むファイルは 1 つだけです。`user_config.rs` は 1 つの文字列を
deserialize していて、`include:` のような仕組みはなく、ルールをワークスペース
ごとに分けることもできません。一部だけを非公開にするには、GlazeWM が読む前に
ファイル全体を組み立てておくしかありません。

追跡している `config.yaml` には、非公開の項目を差し込む位置に目印を置いて
います:

```yaml
      # Machine-specific ignores are spliced in here from ignore-local.txt,
      # which is untracked.
      # LOCAL-IGNORES
```

非公開の項目は `ignore-local.txt` に書きます。このファイルは gitignore の対象
で、1 行に 1 つプロセス名を書くだけです。`Merge-GlazewmConfig.ps1` が追跡側の
ファイルを読み、目印の位置に名前ごとの `- window_process: { equals: '...' }`
の行を生成して差し込み、GlazeWM が読む `~/.glzr/glazewm/config.yaml` に書き
出します。

ローカル側のファイルに YAML ではなく名前だけを書かせているのは意図的です。YAML
はスクリプトが生成するので、追跡していないファイルが追跡側の書式とずれる
ことがありません。

## リロードのキーバインドは合成を実行する

`alt+shift+r` は設定を直接リロードしません。合成スクリプトを実行し、スクリプト
がファイルを書き終えてからリロードを発行します:

```yaml
  - commands: ['shell-exec pwsh -NoProfile -WindowStyle Hidden -File %USERPROFILE%/.glzr/glazewm/Merge-GlazewmConfig.ps1']
    bindings: ['alt+shift+r']
```

こうしているのは、`shell-exec` がプロセスを起動した時点ですぐ戻るためです。
キーバインドに合成とリロードを並べると、その時点でディスクにあるファイル、
つまりたいていは前回の合成結果に対してリロードがかかります。

## スクリプトが書き込みを拒否する 2 つの状況

書き出し先がリポジトリへの symlink であってはいけません。以前は dotfm が張った
symlink になっていて、そこへ生成結果を書くと、非公開の一覧が追跡しているファイル
に入ってしまいます。この仕組み全体で避けたかったことそのものです。スクリプトは
初回の実行でこの symlink を外します。

目印がなければ書きません。この検査がないと、目印を失った土台ファイルから、YAML
として正しく、問題なく読み込まれ、ただローカルのルールだけが入っていない設定が
出来上がります。スクリプトは次のメッセージを出して止まります:

```
Marker '# LOCAL-IGNORES' is missing from …
Nothing would be spliced, so refusing to write a config that silently
drops the local ignores.
```

関連してもう 1 つ。スクリプトはキーバインドから固定のパスで呼べるように、生成
ファイルの隣に symlink で置いてあります。スクリプトの中の `$PSScriptRoot` は
その symlink があるディレクトリ、つまり出力先のディレクトリを指すので、そこを
基準に土台ファイルを読むと、前回生成したファイルを読んで合成に食わせてしまい
ます。目印がないというエラーは、最初この経路で出ました。今のスクリプトは自分の
symlink を辿ってリポジトリ側の土台ファイルを見つけています。
