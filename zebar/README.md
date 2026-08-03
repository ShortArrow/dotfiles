# zebar

GlazeWM 用タスクバー [Zebar](https://github.com/glzr-io/zebar) の設定。

## 構成

- `config.yaml` / `script.js` / `start.bat` / `start.sh` — 旧形式バー（`window/bar`）の設定。
- `overline-zebar/` — submodule。[overline-zebar](https://github.com/mushfikurr/overline-zebar)（React + Vite テーマ）の自分用 fork ([ShortArrow/overline-zebar](https://github.com/ShortArrow/overline-zebar))。

`dotfm.toml` の `[[tools.zebar.links]]` で `~/.glzr/zebar/` 配下へシンボリックリンクされる。Zebar が読むのは各 widget の `dist/`（`.gitignore` 対象）なので、改造後は `pnpm install && pnpm build` が必要。

起動は `pack: overline-zebar` / `widget: main`（`~/.glzr/zebar/settings.json` の `startupConfigs`）。

## 既知の不具合: セッション再接続で落ちる

RDP でログインした状態のまま実機のコンソールでログインすると、zebar が落ちる。
バーが消え、`startup_commands` は GlazeWM の起動時にしか走らないので、手で
起動し直すまで戻らない。

イベントログでの裏付け。Application ログに記録された zebar のクラッシュ 5 件の
うち 4 件が同じ形をしている。

| 日時 | Faulting module | Exception | 直前の再接続 |
|---|---|---|---|
| 2026-08-03 08:02:03 | `ucrtbase.dll` | `0xc0000005` | 同 08:02:03 |
| 2026-07-20 07:23:08 | `ucrtbase.dll` | `0xc0000005` | 07:23:09 |
| 2026-07-17 21:10:02 | `ucrtbase.dll` | `0xc0000005` | 21:09:58 |
| 2026-06-26 19:35:40 | `ucrtbase.dll` | `0xc0000005` | 19:35:39 |
| 2026-07-17 13:10:13 | `zebar.exe` | `0xc0000409` | 該当なし |

4 件はすべて `Microsoft-Windows-TerminalServices-LocalSessionManager/Operational`
の ID 25「Session reconnection succeeded」から 1〜4 秒以内。5 件目は Exception も
faulting module も違い、近くにセッションイベントが無い。別件。

**再接続すれば落ちる、ではない。** 記録されている再接続 10 回のうち、クラッシュを
伴ったのは 4 回。接続元で割れる。

| 接続元 | 再接続 | クラッシュ |
|---|---|---|
| リモート A | 4 | 0 |
| リモート B | 2 | 2 |
| ローカル（コンソール） | 4 | 2 |

コンソールへ戻ったかどうかでは分かれていない。再接続は必要条件で、十分条件では
ない。

### 作業仮説: モニター数の取り決めがずれる

観測された流れは「RDP で先にログイン（1 画面）→ 実機のコンソールでログイン
（3 画面）→ 画面が増える → 落ちる」。**枚数が増える側**でだけ起きているように
見える。上の表でリモート B だけ落ちているのも、そのクライアントが複数画面を
使っているなら同じ説明になる。

材料になる事実:

- クラッシュは `zebar.exe` → `ucrtbase.dll` のネイティブ側で、webview 側では
  ない。widget の React コードは関係しない。
- widget は `zebar.createProviderGroup({ glazewm: { type: 'glazewm' } })` で
  GlazeWM の IPC につながっている。モニターの対応付けは zebar のネイティブ側が
  持つ。
- 現在 GlazeWM が報告するモニターは 3 枚で、**うち 2 枚は `hardwareId` が同じ
  `XMI27A1`**（同型を 2 台）。名前で引く実装があれば 3 枚が 2 件に潰れる。

未検証。GlazeWM 側の一覧は `glazewm query monitors` で取れるが、zebar 側に
対応する出力が無い（`zebar monitors` は 3.3.1 では何も返さない。`start.sh` は
この出力を前提にしているので、現在は 1 つもバーを開かない旧形式の残骸）。

### バージョンは最新（2026-08-03 時点）

| | 導入済み | 最新リリース |
|---|---|---|
| zebar | 3.3.1 | 3.3.1（2026-03-16） |
| GlazeWM | 3.10.1 | 3.10.1（2026-03-21） |

ずれは無い。**上げても直らない。** 両方の `main` にも、リリース後にこの件へ効く
コミットは入っていない（zebar は 2026-03-31 の MediaSession 機能追加が最後、
GlazeWM は 2026-04-08 のテスト整備が最後）。

近い既存 issue はどれも別物。

- zebar #273「2 monitors works fine, 3 does not」は 3.3.1 で修正済み。症状は
  「3 画面でウィジェットが出ない」で、クラッシュではない。
- zebar #206「blanks when unplugging monitors」、#145「bar contents don't load
  after switching dual-monitor setup」— どちらも画面構成の変更まわりだが、
  落ちる報告ではない。
- GlazeWM #1233「Re-adding a disconnected monitor requires a restart」

クラッシュとして報告されているものは見当たらない。

**上流には報告しない。** issue を立てれば追加調査や PR を求められるが、そこに割く
時間が取れない。報告だけして放置するほうが、上流にとっても自分にとっても悪い。
気が変わったときのために、必要な材料はこのページに揃えてある。

- スタック: `zebar.exe 3.3.1` → `ucrtbase.dll` / `0xc0000005` / fault offset `0x7088f`
- 条件: RDP で 1 画面のログイン中に、コンソールで 3 画面のログインをする
- 頻度: 再接続 10 回中 4 回。接続元で割れる（上の表）
- 構成: 同型モニター 2 台が同じ `hardwareId`、加えて別型 1 台

再現手順を確かめるコマンド:

```pwsh
# クラッシュ一覧
Get-WinEvent -FilterHashtable @{LogName='Application'; ProviderName='Application Error'; Id=1000} -MaxEvents 2000 |
  Where-Object { $_.Message -match 'zebar\.exe' } |
  Select-Object TimeCreated, @{n='Mod';e={ if ($_.Message -match 'Faulting module name: ([^,]+)') { $Matches[1] } }}

# 同時刻のセッション操作
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'; Id=24,25}
```

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
