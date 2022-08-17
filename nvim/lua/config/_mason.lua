local M = {}
M.start = function()
  local _mason = require('mason')
  _mason.setup{
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
      }
    }
  }
end
M.setup = function()
  local _mason = require('mason')
  local _nvim_lsp = require('lspconfig')
  local _mason_lspconfig = require('mason-lspconfig')
  local _cmp_nvim_lsp = require('cmp_nvim_lsp')
  local capabilities = _cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

  _mason_lspconfig.setup_handlers({
    function(server_name)
      local _opts = {}

      if server_name == "sumneko_lua" then
        -- https://github.com/folke/lua-dev.nvim/blob/main/lua/lua-dev/sumneko.lua
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua
        local path = { "?.lua", "?/init.lua" }
        _opts.capabilities = capabilities
        _opts.on_attach = function(_, bufnr)
          local _bufopts = { silent = true, buffer = bufnr }
          require("lsp_signature").on_attach(signature_setup, bufnr)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, _bufopts)
          vim.keymap.set('n', 'gtD', vim.lsp.buf.type_definition, _bufopts)
          vim.keymap.set('n', 'grf', vim.lsp.buf.references, _bufopts)
          vim.keymap.set('n', '<space>p', vim.lsp.buf.format, _bufopts)
        end
        _opts.settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
            completion = { callSnippet = "Replace" },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            telemetry = { enable = false },
            runtime = {
              version = "LuaJIT",
              path = path,
            },
          }
        }
      end
      _nvim_lsp[server_name].setup(_opts)
    end
  })
end

 return M
