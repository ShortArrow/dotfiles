local M = {}

M.setup = function()
  require("cmp-plugins").setup({
    -- files = { ".*\\.lua" } -- default
    -- files = { "plugins.lua", "some_path/plugins/" } -- Recommended: use static filenames or partial paths
    files = {
      vim.fn.resolve(vim.fn.stdpath('data') ..'/site/pack/packer/opt'),
      vim.fn.resolve(vim.fn.stdpath('data').. '/site/pack/packer/start'),
      vim.fn.resolve(vim.fn.stdpath('data').. '/site/pack/packer-lib/opt'),
    }
  })
end

return M
