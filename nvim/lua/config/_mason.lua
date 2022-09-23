local api = require('my/api')
local M = {}
M.start = function()
  local _mason = require('mason')
  _mason.setup {
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
  local _nvim_lsp = require('lspconfig')
  local _mason_lspconfig = require('mason-lspconfig')
  local _lsp_sig = require('lsp_signature')
  local _cmp_nvim_lsp = require('cmp_nvim_lsp')
  local capabilities = _cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
  }
  local server_list = {
    "sumneko_lua",
    "intelephense",
    "bashls",
    "marksman",
    "yamlls",
    "dockerls",
    "docker-langserver",
    "pyright",
    "pylsp",
    "pyls",
    "black",
    "pydocstyle",
    "jsonls",
    "tsserver",
  }
  _mason_lspconfig.setup_handlers({
    function(server_name)
      local _opts = {}
      for _, value in ipairs(server_list) do
        if value == server_name then
          _opts.capabilities = capabilities
          _opts.on_attach = function(signature_setup, bufnr)
            _lsp_sig.on_attach(signature_setup, bufnr)
          end
        end
      end
      if server_name == "sumneko_lua" then
        _opts.settings = api.lang.lua.sumneko_lua
      elseif server_name == "intelephense" then
        _opts.settings = api.lang.php.intelephense
      elseif server_name == "pyright" then
        _opts.settings = api.lang.python.pyright
      elseif server_name == "pyls" then
        _opts.settings = api.lang.python.pylsp
      end
      _nvim_lsp[server_name].setup(_opts)
    end
  })
end

return M
