-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- only in windows use pwsh
local is_windows = package.config:sub(1, 1) == '\\'

if is_windows then
  config.default_prog = { 'pwsh' }
end

config.font = wezterm.font 'JetBrainsMonoNL Nerd Font'

config.color_scheme = 'Tokyo Night'
config.color_scheme = 'Tomorrow Night'
config.color_scheme = 'AdventureTime'
config.color_scheme = 'Kibble'

-- config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = 'RESIZE'

config.enable_wayland = false
config.window_background_gradient =
{
  -- orientation = 'Vertical',
  -- preset = 'Cool',
  colors = {
    "#000010",
    "#001020",
    "#000010",
  },
  blend = 'Hsv',
  noise = 200,
  orientation = { Linear = { angle = -45.0 } },
}

config.window_background_opacity = 0.9

-- and finally, return the configuration to wezterm
return config
