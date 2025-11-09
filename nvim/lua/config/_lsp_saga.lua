local M = {}

M.setup = function()
  local saga = require("lspsaga")

  saga.setup({
    ui = {
      border = "rounded",
    },
    hover = {
      open_link = "gx",
    },
    lightbulb = {
      enable = false,
    },
  })
end

return M
