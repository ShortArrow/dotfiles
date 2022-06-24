local depends = require('config._depends')
local keymaps = require('config._keymaps')

local M = {}

M.setup = function()
  keymaps.setup(depends.fugitive)
end

return M
