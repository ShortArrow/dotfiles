local M = {}

M.setup = function()
  vim.g.copilot_no_tab_map = true
  vim.api.nvim_set_keymap("i", "<C-o>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
end

return M
