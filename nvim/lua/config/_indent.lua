local M = {}

M.setup = function()
  local _indent_blankline = require("indent_blankline")

  vim.opt.list = true
  vim.opt.listchars:append "space:⋅"
  vim.opt.listchars:append "eol:↴"

  _indent_blankline.setup {
    show_end_of_line = true,
    space_char_blankline = " ",
  }
end

return M
