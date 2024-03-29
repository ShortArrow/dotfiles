local M = {}

M.concatinate_fontnames = function(list)
  local line
  for key, value in pairs(list) do
    if string.find(value, ' ') then
      value = '\'' .. value .. '\''
    end
    if key == 1 then
      line = value
    else
      line = line .. ',' .. value
    end
  end
  return line
end

M.get_fonts = function()
  local list = {
    'PlemolJPConsoleNF',
    'BlexMono Nerd Font',
    'RbotoJ',
    'cascadia code',
    'Fira Code',
    'Source Code Pro',
    'Consolas',
    'Courier New',
    'monospace',
  }
  return M.concatinate_fontnames(list)
end

return M
