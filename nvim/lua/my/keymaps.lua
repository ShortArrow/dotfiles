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

M.neotest_run = function() require('neotest').run.run() end
M.neotest_run_current = function() require('neotest').run.run(vim.fn.expand("%")) end
M.neotest_run_dap = function() require('neotest').run.run({ strategy = "dap" }) end

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
    { 'ntc', M.neotest_run_current, "Neo Test Run (current run)" },
    { 'ntc', M.neotest_run_dap, "Neo Test Run (dup run)" },
  },
  neogit = {
    { '<Leader>ng', require('neogit').open, },
  },
  ufo = {
    { 'ng', require('ufo').openAllFolds, },
    { 'zM', require('ufo').closeAllFolds, },
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
    { '<Leader>fc', require("telescope").extensions.flutter.commands, },
  },
  trouble = {
    { '<Leader>tr', ':TroubleToggle<CR>', },
  },
  fzflua = {
    { '<Leader>zf', ':FzfLua files<CR>', },
  },
  packer = {
    { mode = 'n', '<Leader>ps', require("packer").sync, },
  },
  vfiler = {
    { '<Leader>vf', ':VFiler<CR>', },
  },
  floaterm = {
    -- normal (Floaterm Normal)
    { '<Leader>fn', ':FloatermNew<CR>', },
    -- lazygit (Floaterm Git)
    { '<Leader>flg', ':FloatermNew lg<CR>', },
    -- lazydocker (Floaterm Docker)
    { '<Leader>flzd', ':FloatermNew lzd<CR>', },
  },
  toggleterm = {
    -- normal (ToggleTerm Normal)
    { '<Leader>tt', require('config/_toggleterm').toggle_repl_term, },
    { '<Leader>flzd', ':FloatermNew lzd<CR>', },
    { mode = 'n', '<C-k>', '<C-w><C-w>W', },
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
    -- show variables infomation
    { '<Leader>lk', vim.lsp.buf.hover, },
    -- jump to definition (Lsp Definition)
    { '<Leader>ld', vim.lsp.buf.definition, },
    -- auto formatting (Lsp Formatting)
    { '<Leader>lf', vim.lsp.buf.format, },
    -- show references (Lsp References)
    { '<Leader>lr', vim.lsp.buf.references, },
    -- rename (Lsp Name)
    -- {  '<Leader>ln',  ':lua vim.lsp.buf.rename()<CR>', },
    -- code_action (Lsp Action)
    -- {  '<Leader>la',  ':lua vim.lsp.buf.code_action()<CR>', },

    -- # window keymaps
    -- go to previous window (Window Previous)
    { '<Leader>wp', '<C-w>p', },
    -- right (Window L)
    { '<Leader>wl', '<C-w>l', },
    -- left (Window H)
    { '<Leader>wh', '<C-w>h', },
    -- down (Window J)
    { '<Leader>wj', '<C-w>j', },
    -- up (Window K)
    { '<Leader>wk', '<C-w>k', },

    -- # buffer keymaps
    -- go to previous buffer (Buffer Previous)
    { '<Leader>bp', ':bprevious<CR>', },
    -- go to next buffer (Buffer Next)
    { '<Leader>bn', ':bnext<CR>', },

    -- # help keymaps
    -- quickref (?)
    { '<Leader>?', ':h quickref<CR>', },
  },
}

return M
