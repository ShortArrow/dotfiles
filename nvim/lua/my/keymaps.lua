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

M.neotest_toggle = function()
  require("neotest").summary.toggle()
end
M.neotest_run = function()
  require("neotest").run.run()
end
M.neotest_run_current = function()
  require("neotest").run.run(vim.fn.expand("%"))
end
M.neotest_run_dap = function()
  require("neotest").run.run({ strategy = "dap" })
end
M.neogit_open = function()
  require("neogit").open()
end
M.ufo_open = function()
  require("ufo").openAllFolds()
end
M.ufo_close = function()
  require("ufo").closeAllFolds()
end
M.flutter_open = function()
  require("telescope").extensions.flutter.commands()
end
M.fm = function()
  require('telescope').extensions.media_files.media_files()
end
M.ff = function()
  require("telescope.builtin").find_files()
end
M.fg = function()
  require("telescope.builtin").live_grep()
end
M.fb = function()
  require("telescope.builtin").buffers()
end
M.fh = function()
  require("telescope.builtin").help_tags()
end
M.fc = function()
  require("telescope.builtin").current_buffer_fuzzy_find()
end
M.packer_sync = function()
  require("packer").sync()
end
M.toggleterm_open = function()
  require("config/_toggleterm").toggle_repl_term()
end
M.rust_tools = {
  hover_actions = function()
    require("rust-tools.hover_actions").hover_actions()
  end,
  code_action_group = {
    code_action_group = function()
      require("rust-tools.code_action_group").code_action_group()
    end,
  },
}
M.maps = {
  aerial = {
    {
      "{",
      "<cmd>AerialPrev<CR>",
    },
    { "}", "<cmd>AerialNext<CR>" },
    -- vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
    -- vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
  },
  lazygit = {
    { "<Leader>lg", ":LazyGit<CR>" },
  },
  rust_tools = {
    { mode = "n", "K", M.rust_tools.hover_actions, desc = "Rust Hover"},
    { mode = "n", "<Leader>ca", M.rust_tools.code_action_group, desc = "Rust Code Action Group"},
  },
  telescope = {
    { "<Leader>ff", M.ff, desc = "Telescope find_files" },
    { "<Leader>fg", M.fg, desc = "Telescope live_grep" },
    { "<Leader>fb", M.fb, desc = "Telescope buffers" },
    { "<Leader>fh", M.fh, desc = "Telescope help_tags" },
    { "<Leader>cb", M.fc, desc = "Telescope current_buffer_fuzzy_find" },
    { "<Leader>fm", M.fm, desc = "Telescope media_files" },
  },
  neotest = {
    { "ntr", M.neotest_run,         desc = "Neo Test Run (nearest run)" },
    { "ntt", M.neotest_toggle,      desc = "Neo Test Summary Open (NeoTest Open)" },
    { "ntc", M.neotest_run_current, desc = "Neo Test Run (current run)" },
    { "ntd", M.neotest_run_dap,     desc = "Neo Test Run (dup run)" },
  },
  neogit = {
    { "<Leader>ng", M.neogit_open },
  },
  ufo = {
    { "ng", M.ufo_open },
    { "zM", M.ufo_close },
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
    { "<Leader>hw", ":HopWord<CR>" },
    { "<Leader>hl", ":HopLine<CR>" },
    { "<Leader>hp", ":HopPattern<CR>" },
  },
  fugitive = {
    { "<Leader>ga",  "keymap" },
    { "<Leader>ga",  ":Git add .<CR>" },
    { "<Leader>gb",  ":Git blame<CR>" },
    { "<Leader>gc",  ":Git commit -m " },
    { "<Leader>gd",  ":Gvdiffsplit<CR>" },
    { "<Leader>gll", ":Gllog<CR>" },
    { "<Leader>glc", ":Gclog<CR>" },
    { "<Leader>gp",  ":Git push<CR>" },
    { "<Leader>gs",  ":Git status<CR>" },
  },
  diffview = {
    { "<Leader>dvh", ":DiffviewFileHistory<CR>" },
    { "<Leader>dvc", ":DiffviewClose<CR>" },
    { "<Leader>dvt", ":DiffviewToggleFiles<CR>" },
    { "<Leader>dvf", ":DiffviewFocusFiles<CR>" },
    { "<Leader>dvr", ":DiffviewRefresh<CR>" },
    { "<Leader>dvo", ":DiffviewOpen<CR>" },
  },
  whichkey = {
    { "<Leader>k", ":WhichKey<CR>" },
  },
  flutter = {
    { mode = "n", "<Leader>fr", ":FlutterRun -d web-server<CR>", desc = "Flutter Run" },
    { mode = "n", "<Leader>fc", M.flutter_open, desc = "Flutter Open" },
  },
  trouble = {
    { "<Leader>tr", ":TroubleToggle<CR>" },
  },
  fzflua = {
    { "<Leader>zf", ":FzfLua files<CR>" },
  },
  packer = {
    { mode = "n", "<Leader>ps", M.packer_sync },
  },
  vfiler = {
    { "<Leader>vf", ":VFiler<CR>" },
  },
  floaterm = {
    { "<Leader>fn",   ":FloatermNew<CR>",     desc = "Floaterm normal" },
    { "<Leader>flg",  ":FloatermNew lg<CR>",  desc = "Floaterm lazygit" },
    { "<Leader>flzd", ":FloatermNew lzd<CR>", desc = "Floaterm lazydocker" },
  },
  toggleterm = {
    { "<Leader>tt", M.toggleterm_open, desc = "ToggleTerm normal" },
    { mode = "n",   "<C-k>",           "<C-w><C-w>W",             desc = "back from ToggleTerm when Normal mode" },
    { mode = "i",   "<C-k>",           "<Esc><C-w>W" },
    { mode = "t",   "<C-k>",           "<C-Bslash><C-n><C-w>W" },
    -- { mode = 'n',  '',  ':', },
    -- { mode = 'i',  '',  '<Esc><C-o>:', },
    -- { mode = 't',  '',  '<C-Bslash><C-n><C-w>:', },
    -- { mode = 'n',  '',  '/', },
    -- { mode = 'i',  '',  '<Esc><C-o>/', },
    -- { mode = 't',  '',  '<C-Bslash><C-n>/', },
  },
  lspsaga = {
    { mode = "n", "<Leader>ln", ":Lspsaga rename<CR>",      desc = "rename (lspsaga)" },
    { mode = "n", "<Leader>la", ":Lspsaga code_action<CR>", desc = "Code Action (lspsaga)" },
    { mode = "n", "<Leader>ls", ":Lspsaga finder<CR>",      desc = "Lsp Search (lspsaga)" },
  },
  common = {
    -- # lsp keymaps
    { "<Leader>lk", vim.lsp.buf.hover,      desc = "show references (Lsp References)" },
    { "<Leader>ld", vim.lsp.buf.definition, desc = "jump to definition (Lsp Definition)" },
    { "<Leader>lf", vim.lsp.buf.format,     desc = "auto formatting (Lsp Formatting)" },
    { "<Leader>lr", vim.lsp.buf.references, desc = "show references (Lsp References)" },
    -- rename (Lsp Name)
    -- {  '<Leader>ln',  ':lua vim.lsp.buf.rename()<CR>', },
    -- code_action (Lsp Action)
    -- {  '<Leader>la',  ':lua vim.lsp.buf.code_action()<CR>', },

    -- # window keymaps
    { "<Leader>wp", "<C-w>p",               desc = "go to previous window (Window Previous)" },
    { "<Leader>wl", "<C-w>l",               desc = "right (Window L)" },
    { "<Leader>wh", "<C-w>h",               desc = "left (Window H)" },
    { "<Leader>wj", "<C-w>j",               desc = "down (Window J)" },
    { "<Leader>wk", "<C-w>k",               desc = "up (Window K)" },

    -- # buffer keymaps
    { "<Leader>bp", ":bprevious<CR>",       desc = "go to previous buffer (Buffer Previous)" },
    { "<Leader>bn", ":bnext<CR>",           desc = "go to next buffer (Buffer Next)" },

    -- # japanese keymaps
    {
      mode = "n",
      "<Down>",
      "gj",
      desc = "IME safe of あ",
    },
    {
      mode = "n",
      "<Up>",
      "gk",
      desc = "IME safe of あ",
    },
    {
      mode = "n",
      "あ",
      "a",
      desc = "IME safe of あ",
    },
    {
      mode = "n",
      "い",
      "i",
      desc = "IME safe of い",
    },
    {
      mode = "n",
      "う",
      "u",
      desc = "IME safe of う",
    },
    {
      mode = "n",
      "お",
      "o",
      desc = "IME safe of お",
    },
    {
      mode = "n",
      "っd",
      "dd",
      desc = "IME safe of dd",
    },
    {
      mode = "n",
      "ｄｄ",
      "dd",
      desc = "IME safe of dd",
    },
    {
      mode = "n",
      "っy",
      "yy",
      desc = "IME safe of yy",
    },
    {
      mode = "n",
      "ｙｙ",
      "yy",
      desc = "IME safe of yy",
    },
    {
      mode = "n",
      'し"',
      'ci"',
      desc = "IME safe of ci",
    },
    {
      mode = "n",
      "し'",
      "ci'",
      desc = "IME safe of ci",
    },
    {
      mode = "n",
      "し”",
      'ci"',
      desc = "IME safe of ci",
    },
    {
      mode = "n",
      "し’",
      "ci'",
      desc = "IME safe of ci",
    },
    {
      mode = "n",
      "：ｗ",
      ":w",
      desc = "IME safe of :w",
    },
    -- { mode = 'n', '<C-S-h>', '<Left>', desc = "IME safe of <Left>" },
    -- { mode = 'n', '<C-S-j>', '<Down>', desc = "IME safe of <Down>" },
    -- { mode = 'n', '<C-S-k>', '<Up>', desc = "IME safe of <Up>" },
    -- { mode = 'n', '<C-S-l>', '<Right>', desc = "IME safe of <Right>" },

    -- # help keymaps
    { "<Leader>?", ":h quickref<CR>" },
  },
}

return M
