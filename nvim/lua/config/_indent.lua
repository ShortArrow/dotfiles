local M = {}

M.setup = function()
  local _indent_blankline = require("indent_blankline")

  -- vim.opt.termguicolors = true
  -- vim.api.nvim_set_hl(0, 'IndentBlanklineIndent1', { fg = "#E06C75" }) -- rainbow
  -- vim.api.nvim_set_hl(0, 'IndentBlanklineIndent2', { fg = "#E5C07B" }) -- rainbow
  -- vim.api.nvim_set_hl(0, 'IndentBlanklineIndent3', { fg = "#98C379" }) -- rainbow
  -- vim.api.nvim_set_hl(0, 'IndentBlanklineIndent4', { fg = "#56B6C2" }) -- rainbow
  -- vim.api.nvim_set_hl(0, 'IndentBlanklineIndent5', { fg = "#61AFEF" }) -- rainbow
  -- vim.api.nvim_set_hl(0, 'IndentBlanklineIndent6', { fg = "#C678DD" }) -- rainbow
  vim.opt.list = true
  -- vim.opt.listchars:append "eol:↴"
  -- vim.opt.listchars:append "space:"
  _indent_blankline.setup {
    show_end_of_line = true,
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
    -- char_highlight_list = { -- rainbow
    --   "IndentBlanklineIndent1", -- rainbow
    --   "IndentBlanklineIndent2", -- rainbow
    --   "IndentBlanklineIndent3", -- rainbow
    --   "IndentBlanklineIndent4", -- rainbow
    --   "IndentBlanklineIndent5", -- rainbow
    --   "IndentBlanklineIndent6", -- rainbow
    -- },
  }
end

return M
