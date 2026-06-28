---
name: tool-call-syntax
description: ツール呼び出し (function call) のタグ構文を壊さないためのチェックリスト。`court` や素の `<invoke>` など存在しないタグで囲むと harness がパースできず "malformed" / "could not be parsed" になり、ツールが一切実行されない (副作用ゼロでユーザに気付かれにくい)。連続して同じ失敗を繰り返した時、ツール結果が返ってこない時、"malformed tool call" を見た時に参照する。
---

# Tool Call Syntax

AI エージェント自身が **ツール呼び出しの XML タグを書き間違える** と、harness が parse に失敗して `Your tool call was malformed and could not be parsed` を返す。このとき **ツールは一切実行されない**。出力やファイル変更などの副作用が無いため、ユーザからは「無言で固まった」「同じ質問を繰り返してくる」ように見え、原因に気付きにくい。

このスキルはその失敗パターンと正しい構文をまとめたもの。

## 実際に起きた失敗

ツール呼び出しを `court` という存在しないタグで囲んでいた:

```
court
<invoke name="Bash">
...
</invoke>
court
```

`court` も素の `<invoke>` も harness の文法ではない。結果、数ターン連続で「malformed」になり、ユーザに毎回「状況は？」と聞かせる事態になった。本人 (AI) は実行したつもりでいるため、ループから抜けにくい。

## 正しい構文

ツール呼び出しは `antml:function_calls` ブロックの中に `antml:invoke` で書く。パラメータは `antml:parameter`。

- ブロック開始/終了: `antml:function_calls`
- 各呼び出し: `antml:invoke`（`name` 属性に正確なツール名）
- 各引数: `antml:parameter`（`name` 属性に引数名）

正しい構造の見本 (下記は山括弧を全角 ＜＞ にして無害化してある。実際の呼び出しでは半角 `<>` を使う):

```
＜antml:function_calls＞
  ＜antml:invoke name="Bash"＞
    ＜antml:parameter name="command"＞ls＜/antml:parameter＞
    ＜antml:parameter name="description"＞list files＜/antml:parameter＞
  ＜/antml:invoke＞
＜/antml:function_calls＞
```

**素の `<invoke>` / `<function_calls>` / `<parameter>` は無効**。必ず `antml:` 接頭辞が付く。`court` のような独自タグで囲むのは論外。

## チェックリスト (呼び出し前に自問)

1. 開きタグは `antml:function_calls` か？ `court` や `function_calls`（接頭辞なし）になっていないか
2. 各ツールは `antml:invoke name="正確なツール名"` で始まっているか
3. 引数は `antml:parameter name="引数名"` か
4. 閉じタグの接頭辞も `antml:` で揃っているか
5. **地の文 (ユーザ向けテキスト) にタグ名を書こうとしていないか** — 説明したいだけなら、実際のタグ構文を地の文に綴らない。誤って起動 or 誤記の原因になる

## 同じ失敗を繰り返さないための復旧手順

`malformed` / `could not be parsed` を見たら、リトライ前に **必ず原因を1つ特定する**。同じ文面でリトライすると同じ失敗を繰り返す (実際に複数ターン浪費した)。

1. 直前の呼び出しの **開きタグ名** を最初に疑う（`court` 等の異物が最有力）
2. タグの `antml:` 接頭辞の有無を確認
3. それでも不明なら、ツールを1つだけ・最小引数で呼んで切り分ける
4. 原因が掴めるまでユーザに同じ質問を投げ続けない（ユーザは「壊れている」としか分からない）

## 注意

- このファイル自体、説明のために壊れたタグ (`court` 等) を **コードブロック内** に書いている。コードブロックの外（地の文や実際の呼び出し）では絶対に使わない。
- 「実行したのに結果が来ない」と感じたら、まず自分の構文を疑う。外部要因 (ツール側の障害) より自分の誤記の方が圧倒的に多い。
