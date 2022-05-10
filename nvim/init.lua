vim.o.number = true
vim.o.termguicolors = true
vim.o.clipboard = vim.o.clipboard..'unnamedplus'
vim.o.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
vim.o.guifont = 'RobotoJ, \'cascadia code\', \'Fira Code\', \'Source Code Pro\', PlemolJP, Consolas, \'Courier New\', monospace'
require'plugins'


-- require('lualine').setup()
require('feline').setup()
-- require('feline').setup({
--     preset = 'noicon'
-- })
-- vim.cmd('Fern . -reveal=% -drawer')
--
vim.g['fern#renderer'] = 'nerdfont'
vim.o.encoding = 'UTF-8'

