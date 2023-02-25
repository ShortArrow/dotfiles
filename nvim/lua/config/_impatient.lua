local M = {}

M.setup = function()
  _G.__luacache_config = {
    chunks = {
      enable = true,
      path = vim.fn.stdpath("cache") .. "/luacache_chunks",
    },
    modpaths = {
      enable = true,
      path = vim.fn.stdpath("cache") .. "/luacache_modpaths",
    },
  }
  local impatient = require("impatient")
  impatient.enable_profile()
end

return M
