local M = {}

-- kakehashi is installed via Mason (see _mason_installer.lua)

M.setup = function()
  if vim.g.__kakehashi_setup_done then return end
  vim.g.__kakehashi_setup_done = true

  -- Disable kakehashi's semantic token for raw blocks so that
  -- treesitter injection highlighting (e.g. TypeScript in code fences)
  -- is not overridden by @lsp.type.string.markdown (priority 125).
  vim.api.nvim_set_hl(0, "@lsp.type.string.markdown", {})
end

return M
