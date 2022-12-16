local M = {}

M.setup = function()
  require("cmp-plugins").setup({
    files = { ".*\\.lua" } -- default
    -- files = { "plugins.lua", "some_path/plugins/" } -- Recommended: use static filenames or partial paths
  })
end

return M
