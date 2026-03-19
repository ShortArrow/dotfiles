local M = {}

M.setup = function()
  local lint = require('lint')
  if vim.fn.executable("vale") == 0 then
    lint.linters_by_ft.markdown = vim.tbl_filter(function(name)
      return name ~= "vale"
    end, lint.linters_by_ft.markdown or {})
  end
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
      lint.try_lint()
    end,
  })
end

return M
