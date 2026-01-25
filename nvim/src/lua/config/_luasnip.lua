local M = {}

M.setup = function()
  local paths = {}
  paths[#paths + 1] = vim.fn.resolve(vim.fn.stdpath('data') .. '/site/pack/packer/opt')
  paths[#paths + 1] = vim.fn.resolve(vim.fn.stdpath('data') .. '/site/pack/packer/start')
  paths[#paths + 1] = vim.fn.resolve(vim.fn.stdpath('data') .. '/site/pack/packer-lib/opt')
  require("luasnip.loaders.from_lua").lazy_load()
  require("luasnip.loaders.from_vscode").lazy_load {
    paths = paths,
  }
  require("luasnip.loaders.from_snipmate").lazy_load()
end

return M
