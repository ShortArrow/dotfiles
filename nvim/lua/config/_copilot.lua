local M = {}

M.setup = function()
  vim.g.copilot_no_tab_map = true
  vim.api.nvim_set_keymap("i", "<C-o>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
  vim.api.nvim_set_keymap("i", "<C-]>", "<Plug>(copilot-dismiss)", { silent = true })
  vim.api.nvim_set_keymap("i", "<M-]>", "<Plug>(copilot-next)", { silent = true })
  vim.api.nvim_set_keymap("i", "<M-[>", "<Plug>(copilot-previous)", { silent = true })
end

return M
