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
  lazygit = {
    name = 'lazygit',
    maps = {
      { map = '<Leader>lg', cmd = ':LazyGit<CR>', },
    },
  },
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
  neogit = {
    name = 'neogit',
    maps = {
      { map = '<Leader>ng', lua = require('neogit').open, },
    },
  },
  ufo = {
    name = 'ufo',
    maps = {
      { map = 'ng', lua = require('ufo').openAllFolds, },
      { map = 'zM', lua = require('ufo').closeAllFolds, },
    },
  },
  hop = {
    name = 'hop',
    maps = {
      -- { mode = 'n', map = 'f',
      --   lua = require('hop').hint_char1({
      --     direction = require('hop.hint').HintDirection.AFTER_CURSOR,
      --     current_line_only = true,
      --   }),
      -- },
      -- { mode = 'n', map = 'F',
      --   lua = require('hop').hint_char1({
      --     direction = require('hop.hint').HintDirection.BEFORE_CURSOR,
      --     current_line_only = true,
      --   }),
      -- },
      -- { mode = 'n', map = 't',
      --   lua = require('hop').hint_char1({
      --     direction = require('hop.hint').HintDirection.AFTER_CURSOR,
      --     current_line_only = true,
      --     hint_offset = -1,
      --   }),
      -- },
      -- { mode = 'n', map = 'T',
      --   lua = require('hop').hint_char1({
      --     direction = require('hop.hint').HintDirection.BEFORE_CURSOR,
      --     current_line_only = true,
      --     hint_offset = -1,
      --   }),
      -- },
      { map = '<Leader>hw', cmd = ':HopWord<CR>', },
      { map = '<Leader>hl', cmd = ':HopLine<CR>', },
      { map = '<Leader>hp', cmd = ':HopPattern<CR>', },
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
      { map = '<Leader>k', cmd = ':WhichKey<CR>', },
    },
  },
  flutter = {
    name = 'flutter',
    maps = {
      { map = '<Leader>fr', cmd = ':FlutterRun -d web-server<CR>', },
      { map = '<Leader>fc', lua = require("telescope").extensions.flutter.commands, },
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
      { mode = 'n', map = '<Leader>ps', lua = require("packer").sync, },
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
      { map = '<Leader>tt', lua = require('config/_toggleterm').toggle_repl_term, },
      { map = '<Leader>flzd', cmd = ':FloatermNew lzd<CR>', },
      { mode = 'n', map = '<C-k>', '<C-w><C-w>W', },
      { mode = 'i', map = '<C-k>', cmd = '<Esc><C-w>W', },
      { mode = 't', map = '<C-k>', cmd = '<C-Bslash><C-n><C-w>W', },
      { mode = 'n', map = '', cmd = ':', },
      { mode = 'i', map = '', cmd = '<Esc><C-o>:', },
      { mode = 't', map = '', cmd = '<C-Bslash><C-n><C-w>:', },
      { mode = 'n', map = '', cmd = '/', },
      { mode = 'i', map = '', cmd = '<Esc><C-o>/', },
      { mode = 't', map = '', cmd = '<C-Bslash><C-n>/', },
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
      { map = '<Leader>lk', lua = vim.lsp.buf.hover, },
      -- jump to definition (Lsp Definition)
      { map = '<Leader>ld', lua = vim.lsp.buf.definition, },
      -- auto formatting (Lsp Formatting)
      { map = '<Leader>lf', lua = vim.lsp.buf.format, },
      -- show references (Lsp References)
      { map = '<Leader>lr', lua = vim.lsp.buf.references, },
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
    if map.mode == nil then
      map.mode = 'n'
    end
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
M.Hop = function() common(M.maps.hop) end
M.Neogit = function() common(M.maps.neogit) end
M.LazyGit = function() common(M.maps.lazygit) end

if _debugger.is_debug then
  _debugger.print('check duplication')
end

return M
