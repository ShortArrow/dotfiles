local M = {}

M.setup = function()
  local mason_nullls = require('mason-null-ls')
  mason_nullls.setup({
    ensure_installed = {
      -- Opt to list sources here, when available in mason.
    },
    automatic_installation = false,
    automatic_setup = true, -- Recommended, but optional
    handlers = {}
  })
end

return M
