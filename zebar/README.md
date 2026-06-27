# zebar

GlazeWM 用タスクバー [Zebar](https://github.com/glzr-io/zebar) の設定。

## 構成

- `config.yaml` / `script.js` / `start.bat` / `start.sh` — 旧形式バー（`window/bar`）の設定。
- `overline-zebar/` — submodule。[overline-zebar](https://github.com/mushfikurr/overline-zebar)（React + Vite テーマ）の自分用 fork ([ShortArrow/overline-zebar](https://github.com/ShortArrow/overline-zebar))。

`dotfm.toml` の `[[tools.zebar.links]]` で `~/.glzr/zebar/` 配下へシンボリックリンクされる。Zebar が読むのは各 widget の `dist/`（`.gitignore` 対象）なので、改造後は `pnpm install && pnpm build` が必要。

起動は `pack: overline-zebar` / `widget: main`（`~/.glzr/zebar/settings.json` の `startupConfigs`）。

## overline-zebar fork のブランチ運用

upstream（`mushfikurr/overline-zebar`）への追従と自分の改造を分離するため、fork は次の3系統で運用する。

| ブランチ | 役割 | 基点 |
|---|---|---|
| `main` | upstream 追従専用。自分のコミットは載せない。 | `upstream/main` をそのままミラー |
| `fix/<機能名>` | upstream へ PR を出す機能別ブランチ。1機能1ブランチで切り出し、PR カードを個別に立てる。 | `upstream/main` から分岐 |
| `custom` | 自分が日常使う統合ブランチ。各 `fix/*` をマージして自分仕様の総体にする。dotfiles の submodule はこれを追跡。 | `upstream/main` から分岐し `fix/*` をマージ |

理由: submodule の `main` に直接改造を積むと、upstream の取り込み（fetch & merge/rebase）が衝突だらけになり追従が破綻する。`main` を純粋なミラーに保つことで `git fetch upstream && git rebase upstream/main`（各 `fix/*` 上で）がクリーンに回る。

### remote 設定（submodule 内）

```sh
# origin = 自分の fork, upstream = 本家
git remote -v
# origin    https://github.com/ShortArrow/overline-zebar
# upstream  https://github.com/mushfikurr/overline-zebar
```

`git reset --hard` で submodule の `user.name` / `user.email` / `user.signingkey` / `upstream` remote が消えることがある。コミット前に `git config user.email` 等を確認し、欠けていたら dotfiles 本体（`git -C <dotfiles> config ...`）から流用する。

### 新しい改造を入れる手順

```sh
cd zebar/overline-zebar
# 1. 機能ブランチを upstream/main から切る
git fetch upstream
git checkout -b fix/<機能名> upstream/main
# ... 実装 ...
git commit -am "feat: ..."
git push -u origin fix/<機能名>          # PR を出す

# 2. custom に取り込む
git checkout custom
git merge --no-ff fix/<機能名>
git push origin custom

# 3. ビルドして dotfiles 側のポインタを更新
pnpm install && pnpm build
cd ../..
git add zebar/overline-zebar
git commit -m "update: bump overline-zebar (...)"
```

### upstream 追従

```sh
cd zebar/overline-zebar
git fetch upstream
git checkout main && git reset --hard upstream/main && git push origin main --force-with-lease
# 各 fix/* を upstream/main に rebase し、custom に取り込み直す
```

> 起動の注意: zebar / glazewm をこのセッションのツール経由で起動するとログがチャットに侵食する。再起動は `schtasks /run /tn GlazeWM_Task` か手動で。
