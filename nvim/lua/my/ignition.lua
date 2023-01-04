local utils = require('my').utils
local debugger = require('my.debugger')
local M = {}

M.start = function()
  local depends = require('my.depends')
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

M.load_plugins = function()
  if debugger.is_debug then
    require('packer-depends')
  else
    require('packer-depends')
    --require('plugin.packer_compiled')
  end
end

return M
