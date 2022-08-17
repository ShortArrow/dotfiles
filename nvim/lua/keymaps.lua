local depends = require('depends')
local debugger = require('debugger')

local keymap = vim.api.nvim_set_keymap
local default_config = { noremap = true, silent = false }

local M = {}

local function _Fugitive()
  keymap('n', '<Leader>ga', ':Git add .<CR>', default_config)
  keymap('n', '<Leader>gb', ':Git blame<CR>', default_config)
  keymap('n', '<Leader>gc', ':Git commit -m ', default_config)
  keymap('n', '<Leader>gd', ':Gvdiffsplit<CR>', default_config)
  keymap('n', '<Leader>gll', ':Gllog<CR>', default_config)
  keymap('n', '<Leader>glc', ':Gclog<CR>', default_config)
  keymap('n', '<Leader>gp', ':Git push<CR>', default_config)
  keymap('n', '<Leader>gs', ':Git status<CR>', default_config)
  -- nnoremap <leader>ga :Git add %:p<CR><CR>
  -- nnoremap <leader>gc :Gcommit<CR><CR>
  -- nnoremap <leader>gs :Gstatus<CR>
  -- nnoremap <leader>gp :Gpush<CR>
  -- nnoremap <leader>gd :Gdiff<CR>
  -- nnoremap <leader>gl :Glog<CR>
  -- nnoremap <leader>gb :Gblame<CR>
  debugger.print("setuped fugitive keymap")
end

local function _Flutter()
  keymap('n', '<Leader>fr', ':FlutterRun -d web-server<CR>',
    default_config)
  keymap('n', '<Leader>fc',
    [[<Cmd>lua require('telescope').extensions.flutter.commands()<CR>]],
    default_config)
  debugger.print("setuped flutter keymap")
end

local function _Trouble()
  keymap('n', '<Leader>tt', ':TroubleToggle<CR>', default_config)
  debugger.print("setuped trouble keymap")
end

local function _FzfLua()
  keymap('n', '<Leader>zf', ':FzfLua files<CR>', default_config)
  debugger.print("setuped fzflua keymap")
end

local function _Packer()
  keymap('n', '<Leader>ps', ':PackerSync<CR>', default_config)
  debugger.print("setuped packer keymap")
end

local function _VFiler()
  keymap('n', '<Leader>vf', ':VFiler<CR>', default_config)
  debugger.print("setuped vfiler keymap")
end

local function _Common()
  -- show variables infomation
  keymap('n', '<Leader>lk', ':lua vim.lsp.buf.hover()<CR>', default_config)
  -- jump to definition
  keymap('n', '<Leader>ld', ':lua vim.lsp.buf.definition()<CR>', default_config)
  -- auto formatting
  keymap('n', '<Leader>lf', ':lua vim.lsp.buf.formatting()<CR>', default_config)
  -- show references
  keymap('n', '<Leader>lr', ':lua vim.lsp.buf.references()<CR>', default_config)
  -- rename
  keymap('n', '<Leader>ln', ':lua vim.lsp.buf.rename()<CR>', default_config)
  -- code_action
  keymap('n', '<Leader>la', ':lua vim.lsp.buf.code_action()<CR>', default_config)
  -- right
  keymap('n', '<Leader>wl', '<C-w>l', default_config)
  -- left
  keymap('n', '<Leader>wh', '<C-w>h', default_config)
  -- down
  keymap('n', '<Leader>wj', '<C-w>j', default_config)
  -- up
  keymap('n', '<Leader>wk', '<C-w>k', default_config)
  debugger.print("setuped common keymap")
end

M.setup = function(depends_arg)
  -- like switch case
  local switchCase = {}
  switchCase[depends.common] = _Common
  switchCase[depends.fugitive] = _Fugitive
  switchCase[depends.flutter] = _Flutter
  switchCase[depends.trouble] = _Trouble
  switchCase[depends.fzflua] = _FzfLua
  switchCase[depends.packer] = _Packer
  switchCase[depends.vfiler] = _VFiler
  switchCase[depends_arg]()
end

return M
