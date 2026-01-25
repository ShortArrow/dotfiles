local M = {}

M.setup = function()
  local _indent_blankline = require("ibl")
  local highlight = {
    "CursorColumn",
    "Whitespace",
  }
  _indent_blankline.setup {
      indent = { highlight = highlight, char = "" },
      whitespace = {
          highlight = highlight,
          remove_blankline_trail = false,
      },
      scope = { enabled = false },
  }
end

return M
