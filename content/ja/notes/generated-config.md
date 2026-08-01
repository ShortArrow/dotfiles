---
title: "生成しなければならない設定"
description: "GlazeWM は 1 ファイルしか読まず include も無い。一部を公開リポジトリから外すには、ウィンドウマネージャが見る前にファイルを組み立てるしかない。"
summary: "分割できない設定を分割する方法と、合成が拒否すべき 2 つの失敗。"
---

GlazeWM の `window_rules` の ignore 一覧には、管理対象から外すアプリケーションが並びます。このマシンでは 11 プロセスあり、いくつかは**同名のリポジトリに直結**します。つまりこの一覧は「どのウィンドウを無視するか」と同じだけ「どんなプロジェクトが存在するか」を語っていました。公開リポジトリに置くには多弁です。

## 継ぎ目が無い

GlazeWM が読むのは 1 ファイルです。`user_config.rs` が単一の文字列を deserialize しており、`include:` はなく、ルールをワークスペース単位に絞ることもできません。**ウィンドウマネージャが見る前に組み立てる**か、諦めるかの二択です。

そこで `config.yaml` にはマーカーだけを置きます。

```yaml
      # Machine-specific ignores are spliced in here from ignore-local.txt,
      # which is untracked.
      # LOCAL-IGNORES
```

`ignore-local.txt` はプロセス名を 1 行 1 つ持つだけで、gitignore 対象です。`Merge-GlazewmConfig.ps1` が行を生成し、`~/.glzr/glazewm/config.yaml` に書き出します。

ローカル側が持つのは **YAML ではなくデータ**です。`- window_process: { equals: '...' }` を素の名前から生成することで、追跡外のファイルが追跡対象と構文的にずれる余地が無くなります。

## リロードは合成を経由する

キーバインドはリロードしません。合成を実行し、**ファイルを書き終えた合成スクリプト側がリロードを発行**します。

```yaml
  - commands: ['shell-exec pwsh -NoProfile -WindowStyle Hidden -File %USERPROFILE%/.glzr/glazewm/Merge-GlazewmConfig.ps1']
    bindings: ['alt+shift+r']
```

`shell-exec` はプロセスの起動と同時に返ります。両方をキーバインドに並べると、その瞬間ディスクにあるもの——たいていは前回の生成物——に対してリロードすることになります。

## 拒否する 2 つの失敗

**配置先を symlink のままにしない。** 元はリポジトリへの symlink でした。生成結果をそこへ書けば、マシン固有の一覧が git に戻ります。避けたかったことそのものです。スクリプトは初回にリンクを外します。

**マーカーが無ければ即座に落とす。** この検査が無いと、マーカーの無い base から**構文的に正しく、正常に読み込まれ、何も無視しない**設定が出来上がります。ローカルのルールが消えるだけです。

```
Marker '# LOCAL-IGNORES' is missing from …
Nothing would be spliced, so refusing to write a config that silently
drops the local ignores.
```

この検査は即座に元を取りました。スクリプトは生成物の隣に symlink されます（キーバインドから安定したパスで届かせるため）。そして `$PSScriptRoot` は**リンク自身のディレクトリ**、つまり出力がある場所を指します。そこから base を読めば、生成物を自分自身に食わせることになります。リンク経由の初回実行でこのエラーが出たので、スクリプトは自分の symlink を辿って源を探すようになっています。
