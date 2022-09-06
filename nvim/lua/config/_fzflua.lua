local M = {}

M.setup = function()
  require("fzf-lua").setup {
    file_icon_padding = ' ',
  }
end

return M
