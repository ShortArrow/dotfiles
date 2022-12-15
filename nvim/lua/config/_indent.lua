local M = {}

M.setup = function()
  local _indent_blankline = require("indent_blankline")

  -- vim.opt.termguicolors = true
  vim.api.nvim_set_hl(0, 'IndentBlanklineIndent1', { fg = "#E06C75" })
  vim.api.nvim_set_hl(0, 'IndentBlanklineIndent2', { fg = "#E5C07B" })
  vim.api.nvim_set_hl(0, 'IndentBlanklineIndent3', { fg = "#98C379" })
  vim.api.nvim_set_hl(0, 'IndentBlanklineIndent4', { fg = "#56B6C2" })
  vim.api.nvim_set_hl(0, 'IndentBlanklineIndent5', { fg = "#61AFEF" })
  vim.api.nvim_set_hl(0, 'IndentBlanklineIndent6', { fg = "#C678DD" })
  vim.opt.list = true
  vim.opt.listchars:append "eol:↴"
  vim.opt.listchars:append "space:⋅"

  _indent_blankline.setup {
    show_end_of_line = true,
    space_char_blankline = " ",
    char_highlight_list = {
      "IndentBlanklineIndent1",
      "IndentBlanklineIndent2",
      "IndentBlanklineIndent3",
      "IndentBlanklineIndent4",
      "IndentBlanklineIndent5",
      "IndentBlanklineIndent6",
    },
  }
end

return M
