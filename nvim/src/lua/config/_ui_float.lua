local M = {}

function M.setup()
  -- Float borders are handled by:
  --   * vim.diagnostic.config (diagnostics.lua)  — diagnostic popups
  --   * LSP Saga (_lsp_saga.lua)                 — hover / signature help
  -- No additional vim.lsp.handlers overrides are needed.
end

return M
