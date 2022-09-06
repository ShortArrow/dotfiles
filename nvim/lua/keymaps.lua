-- ########################################
-- keymap docs template
-- name (Origin of this acronym)
-- ########################################
local debugger = require('debugger')

local keymap = vim.api.nvim_set_keymap

local M = {}

M.maps = {
  fugitive = {
    name = 'fugitive',
    maps = {
      { map = '<Leader>ga', cmd = 'keymap', },
      { map = '<Leader>ga', cmd = ':Git add .<CR>', },
      { map = '<Leader>gb', cmd = ':Git blame<CR>', },
      { map = '<Leader>gc', cmd = ':Git commit -m ', },
      { map = '<Leader>gd', cmd = ':Gvdiffsplit<CR>', },
      { map = '<Leader>gll', cmd = ':Gllog<CR>', },
      { map = '<Leader>glc', cmd = ':Gclog<CR>', },
      { map = '<Leader>gp', cmd = ':Git push<CR>', },
      { map = '<Leader>gs', cmd = ':Git status<CR>', },
    },
  },
  flutter = {
    name = 'flutter',
    maps = {
      { map = '<Leader>fr', cmd = ':FlutterRun -d web-server<CR>', },
      { map = '<Leader>fc', cmd = ':lua require("telescope").extensions.flutter.commands()<CR>', },
    },
  },
  trouble = {
    name = 'trouble',
    maps = {
      { map = '<Leader>tt', cmd = ':TroubleToggle<CR>', },
    },
  },
  fzflua = {
    name = 'fzflua',
    maps = {
      { map = '<Leader>zf', cmd = ':FzfLua files<CR>', },
    },
  },
  packer = {
    name = 'packer',
    maps = {
      { map = '<Leader>ps', cmd = ':lua require("packer").sync()<CR>', },
    },
  },
  vfiler = {
    name = 'vfiler',
    maps = {
      { map = '<Leader>vf', cmd = ':VFiler<CR>', },
    },
  },
  floaterm = {
    name = 'floaterm',
    maps = {
      -- normal (Floaterm Normal)
      { map = '<Leader>fn', cmd = ':FloatermNew<CR>', },
      -- lazygit (Floaterm Git)
      { map = '<Leader>flg', cmd = ':FloatermNew lg<CR>', },
      -- lazydocker (Floaterm Docker)
      { map = '<Leader>flzd', cmd = ':FloatermNew lzd<CR>', },
    },
  },
  lspsaga = {
    name = 'lspsaga',
    maps = {
      -- rename (Lsp Name)
      { map = '<Leader>ln', cmd = ':Lspsaga rename<CR>', },
      -- code_action (Lsp Action)
      { map = '<Leader>la', cmd = ':Lspsaga code_action<CR>', },
    },
  },
  common = {
    name = 'common',
    maps = {
      -- # lsp keymaps
      -- show variables infomation
      { map = '<Leader>lk', cmd = ':lua vim.lsp.buf.hover()<CR>', },
      -- jump to definition (Lsp Definition)
      { map = '<Leader>ld', cmd = ':lua vim.lsp.buf.definition()<CR>', },
      -- auto formatting (Lsp Formatting)
      { map = '<Leader>lf', cmd = ':lua vim.lsp.buf.formatting()<CR>', },
      -- show references (Lsp References)
      { map = '<Leader>lr', cmd = ':lua vim.lsp.buf.references()<CR>', },
      -- rename (Lsp Name)
      -- { map = '<Leader>ln', cmd = ':lua vim.lsp.buf.rename()<CR>', },
      -- code_action (Lsp Action)
      -- { map = '<Leader>la', cmd = ':lua vim.lsp.buf.code_action()<CR>', },

      -- # window keymaps
      -- go to previous window (Window Previous)
      { map = '<Leader>wp', cmd = '<C-w>p', },
      -- right (Window L)
      { map = '<Leader>wl', cmd = '<C-w>l', },
      -- left (Window H)
      { map = '<Leader>wh', cmd = '<C-w>h', },
      -- down (Window J)
      { map = '<Leader>wj', cmd = '<C-w>j', },
      -- up (Window K)
      { map = '<Leader>wk', cmd = '<C-w>k', },

      -- # buffer keymaps
      -- go to previous buffer (Buffer Previous)
      { map = '<Leader>bp', cmd = ':bprevious<CR>', },
      -- go to next buffer (Buffer Next)
      { map = '<Leader>bn', cmd = ':bnext<CR>', },

      -- # help keymaps
      -- quickref (?)
      { map = '<Leader>?', cmd = ':h quickref<CR>', },
    },
  },
}

local merge_default = function(map)
  local default_config = { noremap = true, silent = false }
  -- if not has opt specified, map has no remap and no silent.
  map.opt = map.opt or default_config
  -- if not has mode specified, map has define for nomal mode.
  map.mode = map.mode or 'n'
  return map
end

local set_map = function(map)
  map = merge_default(map)
  keymap(
    tostring(map.mode),
    tostring(map.map),
    tostring(map.cmd),
    map.opt
  )
end

local set_maps = function(maps)
  for _, map in pairs(maps) do
    set_map(map)
  end
end

local common = function(pack)
  set_maps(pack.maps)
  debugger.print("load keymaps of " .. pack.name)
end

M.Fugitive = function()
  common(M.maps.fugitive)
end

M.Flutter = function()
  common(M.maps.flutter)
end

M.Trouble = function()
  common(M.maps.trouble)
end

M.FzfLua = function()
  common(M.maps.fzflua)
end

M.Packer = function()
  common(M.maps.packer)
end

M.VFiler = function()
  common(M.maps.vfiler)
end

M.Common = function()
  common(M.maps.common)
end

M.Floaterm = function()
  common(M.maps.floaterm)
end

M.LspSaga = function()
  common(M.maps.lspsaga)
end

if debugger.is_debug then
  debugger.print('check duplication')
end

return M
