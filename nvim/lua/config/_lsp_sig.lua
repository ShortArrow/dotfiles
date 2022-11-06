local M = {}

M.config = {
  bind = true, -- This is mandatory, otherwise border config won't get registered.
  handler_opts = {
    border = "rounded"
  }
}

M.setup = function()
--  require('lsp_signature').setup(M.config)
end

return M
