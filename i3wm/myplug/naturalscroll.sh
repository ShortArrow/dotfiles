#!/bin/bash
# タッチパッドのデバイス名を取得
TouchpadDevice=$(xinput list | grep 'Touchpad' | awk '{print $6}' | cut -d'=' -f2)

# ナチュラルスクロールを有効にする
if [ -n "$TouchpadDevice" ]; then
	xinput set-prop "$TouchpadDevice" "libinput Natural Scrolling Enabled" 1
fi
