local M = {}

M.start = function()
  local depends = require('my/depends')
  for _, depend in pairs(depends) do
    if depend.enable then
      depend.keymaps()
    end
  end
end

return M
