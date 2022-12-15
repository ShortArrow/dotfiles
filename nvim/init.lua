local ignition = require('my.ignition')
local fonts = require('my.fonts')

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.clipboard:append({ unnamedeplus = true })
vim.opt.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
vim.opt.guifont = fonts.get_fonts()
vim.opt.encoding = 'UTF-8'
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.g.mapleader = " "
vim.opt.pumblend = 5
vim.opt.foldmethod = 'indent'
vim.opt.foldcolumn = '1'
vim.opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.mousemodel = 'extend'
vim.opt.visualbell = true
vim.opt.helplang = 'ja' --, 'en'
vim.opt.fillchars = {
  vert = "│",
  fold = "f",
  eob = "e", -- suppress ~ at EndOfBuffer
  diff = "⣿", -- alternatives = ⣿ ░ ─ ╱
  msgsep = "‾",
  foldopen = "",
  foldsep = "│",
  foldclose = "",
}
vim.opt.listchars = {
  eol = '⤶',
  space = '·',
  trail = '-',
  extends = '◀',
  precedes = '▶',
}

if not pcall(require, "impatient") then
  print "Failed to load impatient."
end
require('packer-depends')
require('config._mason').start()
require('config._mason').setup()
-- local log_path = vim.fn.stdpath('cache') .. '/packer.nvim.log'
-- print log_path
ignition.start()
