vim.o.number = true
vim.o.termguicolors = true
vim.o.clipboard = vim.o.clipboard..'unnamedplus'
vim.o.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
vim.o.guifont = '\'BlexMono Nerd Font\', RobotoJ, \'cascadia code\', \'Fira Code\', \'Source Code Pro\', PlemolJP, Consolas, \'Courier New\', monospace'
vim.o.encoding = 'UTF-8'
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
require'plugins'

vim.cmd[[autocmd BufWritePost plugins.lua PackerCompile]]

