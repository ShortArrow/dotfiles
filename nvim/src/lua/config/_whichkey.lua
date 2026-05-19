local M = {}

M.setup = function()
  require('which-key').setup({
    plugins = {
      registers = true,
    },
  })
end

return M
