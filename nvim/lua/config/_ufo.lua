local M = {}

M.setup = function()
  require('ufo').setup({
    provider_selector = function(bufnr, filetype, buftype)
      return { 'treesitter', 'indent' }
    end

  })
end

return M
