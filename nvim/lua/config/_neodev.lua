local M = {}

M.setup = function()
  -- IMPORTANT: make sure to setup neodev BEFORE lspconfig
  require("neodev").setup({
    -- add any options here, or leave empty to use the default settings
  })
end

return M
