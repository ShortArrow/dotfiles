local M = {}

M.setup = function()
  require('gitsigns').setup({
    attach_to_untracked = false,
    diff_opts = {
      internal = true,
    },
    signcolumn = true,
    numhl      = true,
  })
end

return M
