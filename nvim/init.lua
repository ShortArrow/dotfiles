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
vim.o.foldmethod='indent'
-- packer from here
-- https://github.com/wbthomason/dotfiles/tree/linux/neovim/.config/nvim
function P(...)
  local args = { n = select("#", ...), ... }
  for i = 1, args.n do
    args[i] = vim.inspect(args[i])
  end
  print(unpack(args))
end

if not pcall(require, "impatient") then
  print "Failed to load impatient."
end

require('packer-depends')
-- packer end here

require('config._mason').start()
require('config._mason').setup()
-- local log_path = vim.fn.stdpath('cache') .. '/packer.nvim.log'
-- print log_path
ignition.start()
