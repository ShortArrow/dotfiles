local M = {}

M.setup = function()
  local lint = require('lint')
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
      lint.try_lint()
    end,
  })
end

return M
