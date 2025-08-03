# Claude CodeでsudoをGUI認証で使う方法

Claude Codeでsudoコマンドを実行する際に、GUIでパスワード認証を行う設定方法。

## 問題
Claude Codeからsudoコマンドを実行すると、パスワード入力でプロセスが止まってしまう。

## 解決方法

### 1. askpassスクリプトの作成

```bash
mkdir -p ~/.local/bin
cat > ~/.local/bin/askpass.sh << 'EOF'
#!/bin/bash
export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
exec zenity --password --title='sudo password required'
EOF
chmod +x ~/.local/bin/askpass.sh
```

### 2. 環境変数の設定

```bash
export SUDO_ASKPASS=~/.local/bin/askpass.sh
```

### 3. シェル設定ファイルに追加

```bash
echo 'export SUDO_ASKPASS=~/.local/bin/askpass.sh' >> ~/.bashrc
# または
echo 'export SUDO_ASKPASS=~/.local/bin/askpass.sh' >> ~/.zshrc
```

### 4. 使用方法

Claude Codeで`sudo -A`オプションを使用：

```bash
sudo -A apt update
sudo -A systemctl restart nginx
```

## 技術的な詳細

- `SUDO_ASKPASS`環境変数にスクリプトのパスを設定
- `sudo -A`でaskpassモードを有効化
- zenityを使用してGUIパスワードダイアログを表示
- DISPLAYとXDG_RUNTIME_DIRを明示的に設定することで、sudoの制限された環境でもGUIが動作

## 代替手段

zenityが使えない場合は、他のGUIツールも使用可能：

```bash
# KDE環境の場合
export SUDO_ASKPASS="kdialog --password 'sudo password required'"

# Xの場合
export SUDO_ASKPASS="ssh-askpass"
```