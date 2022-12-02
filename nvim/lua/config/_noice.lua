local M = {}

M.setup = function()
  require("noice").setup({
    lsp = {
      signature = {
        enabled = false
      }
    },
    background_colour = "#000000",
  })
end

return M
