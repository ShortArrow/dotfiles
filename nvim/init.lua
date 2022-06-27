vim.o.number = true
vim.o.termguicolors = true
vim.o.clipboard = vim.o.clipboard..'unnamedplus'
vim.o.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
vim.o.guifont = 'PlemolJP, \'BlexMono Nerd Font\', RobotoJ, \'cascadia code\', \'Fira Code\', \'Source Code Pro\', Consolas, \'Courier New\', monospace'
vim.o.encoding = 'UTF-8'
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.g.mapleader = " "
      vim.api.nvim_set_keymap('n', '<Leader>a',':echo \"HelloLeader\"<CR>'
      , { noremap = true, silent = true })
require'packer-depends'
vim.cmd[[autocmd BufWritePost packer-depends.lua PackerCompile]]

local depends = require('depends')
local keymaps = require('keymaps')

keymaps.setup(depends.trouble)
keymaps.setup(depends.flutter)
keymaps.setup(depends.fugitive)
keymaps.setup(depends.fzflua)
