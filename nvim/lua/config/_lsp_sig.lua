local M = {}

M.on_attach = require('lsp_signature').on_attach
M.setup = function()
--  require('lsp_signature').setup()
  require('lsp_signature').setup({
    bind = true, -- This is mandatory, otherwise border config won't get registered.
    handler_opts = {
      border = "rounded"
    }
  })
end

return M
