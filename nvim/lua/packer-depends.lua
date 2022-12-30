local plugins = require('my.plugins')
local install_path = ("%s/site/pack/packer-lib/opt/packer.nvim"):format(vim.fn.stdpath "data")

local function install_packer()
  vim.fn.termopen(("git clone https://github.com/wbthomason/packer.nvim %q"):format(install_path))
end

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  install_packer()
end

vim.cmd [[packadd packer.nvim]]

function _G.packer_upgrade()
  vim.fn.delete(install_path, "rf")
  install_packer()
end

vim.cmd [[command! PackerUpgrade :call v:lua.packer_upgrade()]]

local _packer = require('packer')

local function spec(use)
  local depends = plugins.ordinalnvim
  for _, depend in pairs(depends) do
    use(depend)
  end
end

_packer.startup {
  spec,
  config = {
    display = {
      open_fn = require("packer.util").float,
    },
    max_jobs = vim.fn.has "win32" == 1 and 5 or nil,
  },
}
