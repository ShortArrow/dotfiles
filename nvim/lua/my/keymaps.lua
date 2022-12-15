-- ########################################
-- keymap docs template
-- name (Origin of this acronym)
-- ########################################
local _api = require('my.api')
local _debugger = _api.debugger

local _keymap = vim.api.nvim_set_keymap
local _set_lua_keymap = function(mode, keymap, luacmd)
  vim.keymap.set(mode, keymap, luacmd)
end

local M = {}

M.maps = {
  neotest = {
    name = 'neotest',
    maps = {
      -- Neo Test Run (nearest run)
      -- { mode = 'n', map = 'ntr', lua = require('neotest').run.run(), },
      -- Neo Test Run (current run)
      --{ mode = 'n', map = 'ntc', lua = require("neotest").run.run(vim.fn.expand("%")), },
      -- Neo Test Run (dup run)
      --{ mode = 'n', map = 'ntc', lua = require("neotest").run.run({strategy = "dap"}), },
    },
  },
  ufo = {
    name = 'ufo',
    maps = {
      { mode = 'n', map = 'zR', lua = require('ufo').openAllFolds, },
      { mode = 'n', map = 'zM', lua = require('ufo').closeAllFolds, },
    },
  },
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
  diffview = {
    name = 'diffview',
    maps = {
      { map = '<Leader>dvh', cmd = ':DiffviewFileHistory<CR>', },
      { map = '<Leader>dvc', cmd = ':DiffviewClose<CR>', },
      { map = '<Leader>dvt', cmd = ':DiffviewToggleFiles<CR>', },
      { map = '<Leader>dvf', cmd = ':DiffviewFocusFiles<CR>', },
      { map = '<Leader>dvr', cmd = ':DiffviewRefresh<CR>', },
      { map = '<Leader>dvo', cmd = ':DiffviewOpen<CR>', },
    },
  },
  whichkey = {
    name = 'whichkey',
    maps = {
      { map = '<Leader>wk', cmd = ':WhichKey<CR>', },
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
      { map = '<Leader>tr', cmd = ':TroubleToggle<CR>', },
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
  toggleterm = {
    name = 'toggleterm',
    maps = {
      -- normal (ToggleTerm Normal)
      { map = '<Leader>tt', cmd = ':ToggleTerm<CR>', },
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
      { map = '<Leader>lf', cmd = ':lua vim.lsp.buf.format()<CR>', },
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
  if map.lua ~= nil then
    _set_lua_keymap(map.mode, map.map, map.lua)
  else
    map = merge_default(map)
    _keymap(
      tostring(map.mode),
      tostring(map.map),
      tostring(map.cmd),
      map.opt
    )
  end
end

local set_maps = function(maps)
  for _, map in pairs(maps) do
    set_map(map)
  end
end

local common = function(pack)
  set_maps(pack.maps)
  _debugger.print("load keymaps of " .. pack.name)
end

M.Fugitive = function() common(M.maps.fugitive) end
M.Flutter = function() common(M.maps.flutter) end
M.Trouble = function() common(M.maps.trouble) end
M.FzfLua = function() common(M.maps.fzflua) end
M.Packer = function() common(M.maps.packer) end
M.VFiler = function() common(M.maps.vfiler) end
M.Common = function() common(M.maps.common) end
M.Floaterm = function() common(M.maps.floaterm) end
M.ToggleTerm = function() common(M.maps.toggleterm) end
M.LspSaga = function() common(M.maps.lspsaga) end
M.WhichKey = function() common(M.maps.whichkey) end
M.Ufo = function() common(M.maps.ufo) end
M.NeoTest = function() common(M.maps.neotest) end
M.DiffView = function() common(M.maps.diffview) end

if _debugger.is_debug then
  _debugger.print('check duplication')
end

return M
