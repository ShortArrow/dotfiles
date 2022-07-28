local depends = require('depends')
local debugger = require('debugger')

local M = {}

local function _Fugitive()
  vim.api.nvim_set_keymap('n', '<Leader>ga',':Git add .<CR>', { noremap = true, silent = false })
  vim.api.nvim_set_keymap('n', '<Leader>gb',':Git blame<CR>', { noremap = true, silent = false })
  vim.api.nvim_set_keymap('n', '<Leader>gc',':Git commit -m ', { noremap = true, silent = false })
  vim.api.nvim_set_keymap('n', '<Leader>gd',':Gvdiffsplit<CR>', { noremap = true, silent = false })
  vim.api.nvim_set_keymap('n', '<Leader>gll',':Gllog<CR>', { noremap = true, silent = false })
  vim.api.nvim_set_keymap('n', '<Leader>glc',':Gclog<CR>', { noremap = true, silent = false })
  vim.api.nvim_set_keymap('n', '<Leader>gp',':Git push<CR>', { noremap = true, silent = false })
  vim.api.nvim_set_keymap('n', '<Leader>gs',':Git status<CR>', { noremap = true, silent = false })
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
  vim.api.nvim_set_keymap('n', '<Leader>fr',':FlutterRun -d web-server<CR>',
        { noremap = true, silent = false })
  vim.api.nvim_set_keymap('n', '<Leader>fc',
        [[<Cmd>lua require('telescope').extensions.flutter.commands()<CR>]],
        { noremap = true, silent = false })
  debugger.print("setuped flutter keymap")
end

local function _Trouble()
  vim.api.nvim_set_keymap('n', '<Leader>tt',':TroubleToggle<CR>', { noremap = true, silent = false })
  debugger.print("setuped trouble keymap")
end

local function _FzfLua()
  vim.api.nvim_set_keymap('n', '<Leader>zf',':FzfLua files<CR>', { noremap = true, silent = false })
  debugger.print("setuped fzflua keymap")
end

local function _Packer()
  vim.api.nvim_set_keymap('n', '<Leader>ps',':PackerSync<CR>', { noremap = true, silent = false })
  debugger.print("setuped packer keymap")
end

local function _VFiler()
  vim.api.nvim_set_keymap('n', '<Leader>vf',':VFiler<CR>', { noremap = true, silent = false })
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
