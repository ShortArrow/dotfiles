local M = {}

M.config = {
  bind = true,
  hint_enable = false,
  floating_window = true,
  handler_opts = { border = "rounded" },
  max_height = 12,
  max_width = 80,
  toggle_key = nil,
}

M.setup = function()
  require('lsp_signature').setup(M.config)
end

return M
