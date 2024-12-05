-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

--
config.default_prog = { 'pwsh' }

config.font = wezterm.font 'JetBrainsMonoNL Nerd Font'

-- For example, changing the color scheme:
config.color_scheme = 'Tokyo Night Night'
config.color_scheme = 'Tomorrow Night Night'
config.color_scheme = 'AdventureTime'

-- and finally, return the configuration to wezterm
return config
