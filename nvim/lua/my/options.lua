local M = {}
local g = vim.g
local opt = vim.opt
local fonts = require("my.fonts")

M.activate = function()
  g.mapleader = " "
  g.copilot_no_tab_map = true -- GitHub Copilot
  opt.number = true
  opt.relativenumber = true
  opt.termguicolors = true
  opt.ignorecase = true -- (default : off)
  opt.smartcase = true  -- (default : off)
  opt.clipboard = "unnamedplus"
  opt.cursorlineopt = "number"
  opt.cursorline = true
  opt.guicursor =
  "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
  opt.guifont = fonts.get_fonts()
  opt.encoding = "UTF-8"
  opt.fileencodings = { "UTF-8", "sjis" }
  opt.fileformat = "unix" -- use LF
  opt.fileencoding = ""
  opt.expandtab = true
  opt.smartindent = true -- (default : off)
  opt.tabstop = 2
  opt.shiftwidth = 2
  opt.pumblend = 5
  opt.foldmethod = "indent"
  opt.foldcolumn = "1"
  opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
  opt.foldlevelstart = 99
  opt.foldenable = true
  opt.mousemodel = "extend"
  opt.visualbell = true
  opt.helplang = "ja" --, 'en'
  opt.inccommand = "split"
  opt.fillchars = {
    vert = "│",
    fold = "f",
    eob = "e", -- suppress ~ at EndOfBuffer
    diff = "⣿", -- alternatives = ⣿ ░ ─ ╱
    msgsep = "‾",
    foldopen = "",
    foldsep = "│",
    foldclose = "",
  }
  opt.listchars = {
    eol = "⤶",
    space = "·",
    trail = "-",
    extends = "◀",
    precedes = "▶",
  }
end

local windows_ff_group = vim.api.nvim_create_augroup("WindowsFileFormat", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.bat", "*.cmd", "*.cs", "*.ps1" },
  command = "setlocal fileformat=dos",
  group = windows_ff_group,
})

return M
