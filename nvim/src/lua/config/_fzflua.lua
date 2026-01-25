local M = {}

M.setup = function()
  require("fzf-lua").setup {
    file_icon_padding = ' ',
    lsp = {
      -- make lsp requests synchronous so they work with null-ls
      async_or_timeout = 3000,
    },
  }
end

return M
