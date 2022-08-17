local M = {}
local _indent_blankline = require("indent_blankline")

M.setup = function()
  vim.g['fern#renderer'] = 'nerdfont'
end

return M
