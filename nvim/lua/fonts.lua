local debugger = require('debugger')

local M = {}

M.list = {
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

M.get_fonts = function()
  local line
  for key, value in pairs(M.list) do
    if key == 1 then
      line = value
    else
      line = line .. value
    end
  end
  debugger.print('fonts: ' .. line)
  return line
end

return M
