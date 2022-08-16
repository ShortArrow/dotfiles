local M = {}

M.setup = function()
  local _mason = require('mason')
  local _nvim_lsp = require('lspconfig')
  local _mason_lspconfig = require('mason-lspconfig')

  _mason.setup{
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
      }
    }
  }
  _mason_lspconfig.setup_handlers({ function(server_name)
    local _opts = {}
    _opts.on_attach = function(_, bufnr)
      local _bufopts = { silent = true, buffer = bufnr }
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, _bufopts)
      vim.keymap.set('n', 'gtD', vim.lsp.buf.type_definition, _bufopts)
      vim.keymap.set('n', 'grf', vim.lsp.buf.references, _bufopts)
      vim.keymap.set('n', '<space>p', vim.lsp.buf.format, _bufopts)
    end
    _nvim_lsp[server_name].setup(_opts)
  end })

  _mason_lspconfig.setup_handlers({
    function(server_name)
      local _opts = {}

      if server_name == "sumneko_lua" then
        _opts.settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
          }
        }
      end

      _nvim_lsp[server_name].setup(_opts)
    end
  })
end

 return M
