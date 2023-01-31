local M = {}

M.commonmaps_activate = function()
  for _, map in pairs(M.maps.common) do
    if "string" == type(map[2]) then
      vim.api.nvim_set_keymap("n", map[1], map[2], {})
    else
      vim.keymap.set("n", map[1], map[2])
    end
  end
end

M.neotest_open = function() require('neotest').summary.open() end
M.neotest_run = function() require('neotest').run.run() end
M.neotest_run_current = function() require('neotest').run.run(vim.fn.expand("%")) end
M.neotest_run_dap = function() require('neotest').run.run({ strategy = "dap" }) end
M.neogit_open = function() require('neogit').open() end
M.ufo_open = function() require('ufo').openAllFolds() end
M.ufo_close = function() require('ufo').closeAllFolds() end
M.flutter_open = function() require("telescope").extensions.flutter.commands() end
M.packer_sync = function() require("packer").sync() end
M.toggleterm_open = function() require('config/_toggleterm').toggle_repl_term() end
M.maps = {
  aerial = {
    { '{', '<cmd>AerialPrev<CR>', },
    { '}', '<cmd>AerialNext<CR>', },
    -- vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
    -- vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
  },
  lazygit = {
    { '<Leader>lg', ':LazyGit<CR>', },
  },
  neotest = {
    { 'ntr', M.neotest_run, desc = "Neo Test Run (nearest run)" },
    { 'nto', M.neotest_open, desc = "Neo Test Summary Open (NeoTest Open)" },
    { 'ntc', M.neotest_run_current, desc = "Neo Test Run (current run)" },
    { 'ntd', M.neotest_run_dap, desc = "Neo Test Run (dup run)" },
  },
  neogit = {
    { '<Leader>ng', M.neogit_open, },
  },
  ufo = {
    { 'ng', M.ufo_open, },
    { 'zM', M.ufo_close, },
  },
  hop = {
    -- { mode = 'n',  'f',
    --  require('hop').hint_char1({
    --     direction = require('hop.hint').HintDirection.AFTER_CURSOR,
    --     current_line_only = true,
    --   }),
    -- },
    -- { mode = 'n',  'F',
    --  require('hop').hint_char1({
    --     direction = require('hop.hint').HintDirection.BEFORE_CURSOR,
    --     current_line_only = true,
    --   }),
    -- },
    -- { mode = 'n',  't',
    --  require('hop').hint_char1({
    --     direction = require('hop.hint').HintDirection.AFTER_CURSOR,
    --     current_line_only = true,
    --     hint_offset = -1,
    --   }),
    -- },
    -- { mode = 'n',  'T',
    --  require('hop').hint_char1({
    --     direction = require('hop.hint').HintDirection.BEFORE_CURSOR,
    --     current_line_only = true,
    --     hint_offset = -1,
    --   }),
    -- },
    { '<Leader>hw', ':HopWord<CR>', },
    { '<Leader>hl', ':HopLine<CR>', },
    { '<Leader>hp', ':HopPattern<CR>', },
  },
  fugitive = {
    { '<Leader>ga', 'keymap', },
    { '<Leader>ga', ':Git add .<CR>', },
    { '<Leader>gb', ':Git blame<CR>', },
    { '<Leader>gc', ':Git commit -m ', },
    { '<Leader>gd', ':Gvdiffsplit<CR>', },
    { '<Leader>gll', ':Gllog<CR>', },
    { '<Leader>glc', ':Gclog<CR>', },
    { '<Leader>gp', ':Git push<CR>', },
    { '<Leader>gs', ':Git status<CR>', },
  },
  diffview = {
    { '<Leader>dvh', ':DiffviewFileHistory<CR>', },
    { '<Leader>dvc', ':DiffviewClose<CR>', },
    { '<Leader>dvt', ':DiffviewToggleFiles<CR>', },
    { '<Leader>dvf', ':DiffviewFocusFiles<CR>', },
    { '<Leader>dvr', ':DiffviewRefresh<CR>', },
    { '<Leader>dvo', ':DiffviewOpen<CR>', },
  },
  whichkey = {
    { '<Leader>k', ':WhichKey<CR>', },
  },
  flutter = {
    { '<Leader>fr', ':FlutterRun -d web-server<CR>', },
    { '<Leader>fc', M.flutter_open, },
  },
  trouble = {
    { '<Leader>tr', ':TroubleToggle<CR>', },
  },
  fzflua = {
    { '<Leader>zf', ':FzfLua files<CR>', },
  },
  packer = {
    { mode = 'n', '<Leader>ps', M.packer_sync, },
  },
  vfiler = {
    { '<Leader>vf', ':VFiler<CR>', },
  },
  floaterm = {
    { '<Leader>fn', ':FloatermNew<CR>', desc = "Floaterm normal" },
    { '<Leader>flg', ':FloatermNew lg<CR>', desc = "Floaterm lazygit" },
    { '<Leader>flzd', ':FloatermNew lzd<CR>', desc = "Floaterm lazydocker" },
  },
  toggleterm = {
    { '<Leader>tt', M.toggleterm_open, desc = "ToggleTerm normal" },
    { mode = 'n', '<C-k>', '<C-w><C-w>W', desc = "back from ToggleTerm when Normal mode" },
    { mode = 'i', '<C-k>', '<Esc><C-w>W', },
    { mode = 't', '<C-k>', '<C-Bslash><C-n><C-w>W', },
    -- { mode = 'n',  '',  ':', },
    -- { mode = 'i',  '',  '<Esc><C-o>:', },
    -- { mode = 't',  '',  '<C-Bslash><C-n><C-w>:', },
    -- { mode = 'n',  '',  '/', },
    -- { mode = 'i',  '',  '<Esc><C-o>/', },
    -- { mode = 't',  '',  '<C-Bslash><C-n>/', },
  },
  lspsaga = {
    -- rename (Lsp Name)
    { '<Leader>ln', ':Lspsaga rename<CR>', },
    -- code_action (Lsp Action)
    { '<Leader>la', ':Lspsaga code_action<CR>', },
  },
  common = {
    -- # lsp keymaps
    { '<Leader>lk', vim.lsp.buf.hover, desc = "show references (Lsp References)" },
    { '<Leader>ld', vim.lsp.buf.definition, desc = "jump to definition (Lsp Definition)" },
    { '<Leader>lf', vim.lsp.buf.format, desc = "auto formatting (Lsp Formatting)" },
    { '<Leader>lr', vim.lsp.buf.references, desc = "show references (Lsp References)" },
    -- rename (Lsp Name)
    -- {  '<Leader>ln',  ':lua vim.lsp.buf.rename()<CR>', },
    -- code_action (Lsp Action)
    -- {  '<Leader>la',  ':lua vim.lsp.buf.code_action()<CR>', },

    -- # window keymaps
    { '<Leader>wp', '<C-w>p', desc = "go to previous window (Window Previous)" },
    { '<Leader>wl', '<C-w>l', desc = "right (Window L)" },
    { '<Leader>wh', '<C-w>h', desc = "left (Window H)" },
    { '<Leader>wj', '<C-w>j', desc = "down (Window J)" },
    { '<Leader>wk', '<C-w>k', desc = "up (Window K)" },

    -- # buffer keymaps
    { '<Leader>bp', ':bprevious<CR>', desc = "go to previous buffer (Buffer Previous)" },
    { '<Leader>bn', ':bnext<CR>', desc = "go to next buffer (Buffer Next)" },

    -- # help keymaps
    { '<Leader>?', ':h quickref<CR>', },
  },
}

return M
