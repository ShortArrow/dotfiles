local M = {}
M.lsp_sig_config = {
  bind = true, -- This is mandatory, otherwise border config won't get registered.
  handler_opts = {
    border = "rounded"
  }
}
M.setup = function()
  local _mason = require('mason')
  -- Define the sign for a breakpoint
  vim.fn.sign_define('DapBreakpoint', { text = ' ', texthl = 'ErrorMsg', linehl = '', numhl = '' })
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
