local depends = require('depends')
local debugger = require('debugger')

local keymap = vim.api.nvim_set_keymap
local default_conf = { noremap = true, silent = false }

local M = {}

local function _Fugitive()
  keymap('n', '<Leader>ga',':Git add .<CR>', default_conf)
  keymap('n', '<Leader>gb',':Git blame<CR>', default_conf)
  keymap('n', '<Leader>gc',':Git commit -m ', default_conf)
  keymap('n', '<Leader>gd',':Gvdiffsplit<CR>', default_conf)
  keymap('n', '<Leader>gll',':Gllog<CR>', default_conf)
  keymap('n', '<Leader>glc',':Gclog<CR>', default_conf)
  keymap('n', '<Leader>gp',':Git push<CR>', default_conf)
  keymap('n', '<Leader>gs',':Git status<CR>', default_conf)
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
  keymap('n', '<Leader>fr',':FlutterRun -d web-server<CR>',
        default_conf)
  keymap('n', '<Leader>fc',
        [[<Cmd>lua require('telescope').extensions.flutter.commands()<CR>]],
        default_conf)
  debugger.print("setuped flutter keymap")
end

local function _Trouble()
  keymap('n', '<Leader>tt',':TroubleToggle<CR>', default_conf)
  debugger.print("setuped trouble keymap")
end

local function _FzfLua()
  keymap('n', '<Leader>zf',':FzfLua files<CR>', default_conf)
  debugger.print("setuped fzflua keymap")
end

local function _Packer()
  keymap('n', '<Leader>ps',':PackerSync<CR>', default_conf)
  debugger.print("setuped packer keymap")
end

local function _VFiler()
  keymap('n', '<Leader>vf',':VFiler<CR>', default_conf)
  debugger.print("setuped vfiler keymap")
end

M.setup = function(depends_arg)
  -- like switch case
  local switchCase = {}
  switchCase[depends.fugitive] = _Fugitive
  switchCase[depends.flutter] = _Flutter
  switchCase[depends.trouble] = _Trouble
  switchCase[depends.fzflua] = _FzfLua
  switchCase[depends.packer] = _Packer
  switchCase[depends.vfiler] = _VFiler
  switchCase[depends_arg]()
end

return M
