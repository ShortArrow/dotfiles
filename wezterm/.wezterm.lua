-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- only in windows use pwsh
local is_windows = package.config:sub(1, 1) == '\\'

if is_windows then
  config.default_prog = { 'pwsh' }
else
  config.default_prog = { 'bash' }
end

config.font = wezterm.font_with_fallback {
  'JetBrainsMonoNL Nerd Font',
  'Cica',
  'Consolas',
  'Noto Sans CJK JP',
  'Noto Color Emoji',
}
config.font_size = 10.0

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

config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- convert dotnet link "V:\path\to\file.cs (123,45)" to "editor://..."
table.insert(config.hyperlink_rules, {
  -- drive:\path\to\file (line,col)
  regex = [[([A-Za-z]:[^\s()]+)\s*\((\d+),(\d+)\)]],
  format = 'editor://$1:$2:$3',
})

wezterm.on('open-uri', function(_, _, uri) -- _window, _pane
  wezterm.log_info('open-uri received: ' .. uri)
  local editor_scheme = 'editor://'
  if uri:sub(1, #editor_scheme) ~= editor_scheme then
    return true
  end

  local path_with_coords = uri:sub(#editor_scheme + 1)
  local path, line, col = path_with_coords:match('^(.*):(%d+):(%d+)$')
  if not path then
    path, line = path_with_coords:match('^(.*):(%d+)$')
  end
  if not path or not line then
    wezterm.log_error('Failed to parse editor uri: ' .. uri)
    return true
  end

  local line_num = tonumber(line) or 1
  local col_num = tonumber(col) or 1
  local editor = os.getenv('WEZTERM_EDITOR') or 'code'
  local target = string.format('%s:%d:%d', path, line_num, col_num)
  local cmd
  if is_windows then
    cmd = { 'cmd.exe', '/c', editor, '--goto', target }
  else
    cmd = { editor, '--goto', target }
  end

  wezterm.log_info('Opening in VS Code: ' .. table.concat(cmd, ' '))
  wezterm.run_child_process(cmd)
  return false
end)

-- and finally, return the configuration to wezterm
return config
