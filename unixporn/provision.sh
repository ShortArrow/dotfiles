#!/bin/sh

# Check if required environment variables are set
#: "${terminal:?Environment variable \$terminal must be set}"

# Update system latest
sudo pacman -Syu --noconfirm
sudo pacman -S \
	gnome-keyring \
	gdm wayland xorg-xwayland hyprland \
	dunst pipewire wireplumber qt5-wayland qt6-wayland polkit-kde-agent \
	vim neovim wezterm kitty alacritty \
	--noconfirm

# Create link xinitrc
ln -s /vagrant/xinitrc ~/.xinitrc

# Customize Hyprland configuration
mkdir -p ~/.config/hypr
ln -s /vagrant/startup.sh ~/.config/hypr/startup.sh
ln -s /vagrant/hyprland.conf ~/.config/hypr/hyprland.conf

# Set Hyprland session for GDM
sudo mkdir -p /usr/share/wayland-sessions
sudo ln -s /vagrant/hyprland.desktop /usr/share/wayland-sessions/hyprland.desktop

# Enable GDM
sudo systemctl enable gdm
# Start GDM
sudo systemctl start gdm
