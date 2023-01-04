local plugins = require('my.plugins')

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

vim.cmd [[command! PackerUpgrade :call v:lua.packer_upgrade()]]

local _packer = require('packer')

local function spec(use)
  local depends = plugins.ordinalnvim
  for _, depend in pairs(depends) do
    use(depend)
  end
  if packer_bootstrap then
    require('packer').sync()
  end
end

_packer.startup {
  spec,
  config = {
    display = {
      open_fn = function()
        return require('packer.util').float({ border = 'single' })
      end
    },
    max_jobs = vim.fn.has "win32" == 1 and 5 or nil,
  },
}
