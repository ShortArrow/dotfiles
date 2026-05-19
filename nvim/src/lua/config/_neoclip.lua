local M = {}

M.setup = function()
  require("neoclip").setup({})
  pcall(function()
    require("telescope").load_extension("neoclip")
  end)
end

return M
