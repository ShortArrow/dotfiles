local M = {}

M.config = {
  bind = true,
  hint_enable = false,
  floating_window = false,
  handler_opts = { border = "rounded" },
}

M.setup = function()
  -- Disabled to avoid deprecated API noise; rely on built-in signature help or cmp-nvim-lsp-signature-help
  -- require('lsp_signature').setup(M.config)
end

return M
