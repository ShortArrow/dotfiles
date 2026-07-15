local M = {}
M.lsp_sig_config = {
  bind = true, -- This is mandatory, otherwise border config won't get registered.
  handler_opts = {
    border = "rounded"
  }
}
local function get_project_root()
  local output = vim.fn.systemlist('git rev-parse --show-toplevel')
  if vim.v.shell_error ~= 0 or #output == 0 then
    return nil
  end

  return output[1]
end

M.setup = function()
  local _api = require('my')
  local _mason = require('mason')
  local _mason_lspconfig = require('mason-lspconfig')
  local _mason_nullls = require('mason-null-ls')
  local _mason_dap = require("mason-nvim-dap")
  local _dap = require('dap')
  -- Define the sign for a breakpoint
  vim.fn.sign_define('DapBreakpoint', { text = ' ', texthl = 'ErrorMsg', linehl = '', numhl = '' })
  local capabilities = require('blink.cmp').get_lsp_capabilities()
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
  }
  _mason.setup {
    ui = {
      icons = {
        package_installed = "✓ ",
        package_pending = "➜ ",
        package_uninstalled = "✗ "
      }
    }
  }

  -- Set bordered LSP hover/signature help globally
  require("config._ui_float").setup()
end

return M
