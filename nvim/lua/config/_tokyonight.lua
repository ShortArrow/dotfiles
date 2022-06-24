local M = {}

function M.setup()
  require('tokyonight')
  vim.g.tokyonight_style = "night"
  vim.g.tokyonight_italic_functions = true
  vim.g.tokyonight_dark_sidebar = true
  vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }
  vim.g.tokyonight_colors = { hint = "orange", error = "#ff0000" }
  vim.cmd[[colorscheme tokyonight]]
end

return M
