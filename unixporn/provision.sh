#!/bin/sh

# Check if required environment variables are set
#: "${terminal:?Environment variable \$terminal must be set}"

# Update system latest
sudo pacman -Syu --noconfirm
sudo pacman -S \
	gnome-keyring \
	gdm wayland xorg-xwayland hyprland waybar \
	hyprpaper wofi rofi cliphist brightnessctl hypridle hyprlock \
	dunst pipewire wireplumber qt5-wayland qt6-wayland polkit-kde-agent \
	thunar dolphin network-manager-applet \
	vim neovim wezterm kitty alacritty foot \
  firefox \
	--noconfirm

# Create link xinitrc
rm -f ~/.xinitrc
ln -s /vagrant/xinitrc ~/.xinitrc

# Create link xprofile
rm -f ~/.xprofile
ln -s /vagrant/.xprofile ~/.xprofile

# Customize Hyprland configuration
mkdir -p ~/.config/hypr
rm -f ~/.config/hypr/startup.sh
ln -s /vagrant/startup.sh ~/.config/hypr/startup.sh
rm -f ~/.config/hypr/hyprland.conf
ln -s /vagrant/hyprland.conf ~/.config/hypr/hyprland.conf

# Set Hyprland session for GDM
sudo mkdir -p /usr/share/wayland-sessions
sudo rm -f /usr/share/wayland-sessions/hyprland.desktop
sudo ln -s /vagrant/hyprland.desktop /usr/share/wayland-sessions/hyprland.desktop

# Enable GDM
sudo systemctl enable gdm
# Start GDM
sudo systemctl start gdm
