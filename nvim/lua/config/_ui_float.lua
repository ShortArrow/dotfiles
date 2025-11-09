local M = {}

local function apply_highlights()
  -- No-op: respect theme-provided FloatBorder/NormalFloat entirely.
end

function M.setup()
  -- Borders for all LSP popups
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
  vim.diagnostic.config({ float = { border = "rounded" } })

  apply_highlights()
end

return M
