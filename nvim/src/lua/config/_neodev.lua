local M = {}

M.setup = function()
  local neodev = require('neodev')
  neodev.setup({
    library = { plugins = { "neotest" }, types = true },
  })
end

return M
