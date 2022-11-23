local M = {}

M.setup = function()
  require("noice").setup({
    lsp = {
      signature = {
        enabled = false
      }
    }
  })
  require("notify").setup({ background_colour = "#000000", })
end

return M