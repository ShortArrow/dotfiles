local M = {}
M.lsp_sig_config = {
  bind = true, -- This is mandatory, otherwise border config won't get registered.
  handler_opts = {
    border = "rounded"
  }
}
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
  local capabilities = _cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
  }
  _mason_lspconfig.setup_handlers({
    function(server_name)
      local _api = require('my/api')
      local _opts = {}
      _opts.capabilities = capabilities
      _opts.on_attach = function(_, bufnr)
        _lsp_sig.on_attach(M.lsp_sig_config, bufnr)
      end
      if server_name == "sumneko_lua" then
        _opts.settings = _api.lang.lua.sumneko_lua
      elseif server_name == "intelephense" then
        _opts.settings = _api.lang.php.intelephense
      elseif server_name == "pyright" then
        _opts.settings = _api.lang.python.pyright
      elseif server_name == "pyls" then
        _opts.settings = _api.lang.python.pylsp
      elseif server_name == "powershell_es" then
        print('load mason config of pwsh')
        _opts.settings = _api.lang.pwsh.powershell_es
      end
      _nvim_lsp[server_name].setup(_opts)
    end
  })
end

return M
