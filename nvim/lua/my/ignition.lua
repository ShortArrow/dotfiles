local utils = require('my.api').utils
local M = {}

M.start = function()
  local depends = require('my/depends')
  for _, depend in pairs(depends) do
    if nil == depend.disable or utils.is_boolean(depend.disable) and not depend.disable then
      if utils.is_function(depend.keymaps) then
        depend.keymaps()
      end
      if utils.is_function(depend.env) then
        depend.env()
      end
    end
  end
end

return M
