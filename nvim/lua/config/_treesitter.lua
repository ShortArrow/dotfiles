local M = {}

M.setup = function()
  require('nvim-treesitter.configs').setup {
    context_commentstring = {
      enable = true
    }
  }
end

return M
