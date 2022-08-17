
local M = {}

M.setup = function()
  local nvim_lsp = require('lspconfig')
  local _mason_lspconfig = require('mason-lspconfig')
  _mason_lspconfig.setup_handlers({
    function(server_name)
      local opts = {}

      if server_name == "sumneko_lua" then
        opts.settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
          }
        }
      end

      nvim_lsp[server_name].setup(opts)
    end
  })
end

return M
