local ignition = require('my/ignition')
local fonts = require('my/fonts')

vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.o.clipboard = vim.o.clipboard .. 'unnamedplus'
vim.o.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
vim.o.guifont = fonts.get_fonts()
vim.o.encoding = 'UTF-8'
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.g.mapleader = " "
vim.o.pumblend = 5
vim.o.foldmethod = 'indent'
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.mousemodel = 'extend'

if not pcall(require, "impatient") then
  print "Failed to load impatient."
end
require('packer-depends')
require('config._mason').start()
require('config._mason').setup()
-- local log_path = vim.fn.stdpath('cache') .. '/packer.nvim.log'
-- print log_path
ignition.start()
-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
