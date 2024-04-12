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
    {
      mode = "n",
      "K",
      function()
        require("rust-tools.hover_actions").hover_actions()
      end,
      desc = "Rust Hover"
    },
    {
      mode = "n",
      "<Leader>ca",
      function()
        require("rust-tools.code_action_group").code_action_group()
      end,
      desc = "Rust Code Action Group"
    },
  },
  neotest = {
    { "ntr", function() require("neotest").run.run() end,                     desc = "Neo Test Run (nearest run)" },
    { "ntt", function() require("neotest").summary.toggle() end,              desc = "Neo Test Summary Open (NeoTest Open)" },
    { "ntc", function() require("neotest").run.run(vim.fn.expand("%")) end,   desc = "Neo Test Run (current run)" },
    { "ntd", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Neo Test Run (dup run)" },
  },
  neogit = {
    { "<Leader>ng", function() require("neogit").open() end },
  },
  ufo = {
    { "ng", function() require("ufo").openAllFolds() end },
    { "zM", function() require("ufo").closeAllFolds() end },
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
    { "<Leader>km", ":WhichKey<CR>" },
  },
  flutter = {
    { mode = "n", "<Leader>fr", ":FlutterRun -d web-server<CR>",                                   desc = "Flutter Run" },
    { mode = "n", "<Leader>fc", function() require("telescope").extensions.flutter.commands() end, desc = "Flutter Open" },
  },
  trouble = {
    { "<Leader>tr", ":TroubleToggle<CR>" },
  },
  fzflua = {
    { "<Leader>zf", ":FzfLua files<CR>" },
  },
  packer = {
    { mode = "n", "<Leader>ps", function() require("packer").sync() end },
  },
  vfiler = {
    { "<Leader>vf", ":VFiler<CR>" },
  },
  toggleterm = {
    {
      "<Leader>tt",
      function() require("config/_toggleterm").toggle_repl_term() end,
      desc = "ToggleTerm normal"
    },
    { mode = "n", "<C-k>", "<C-w><C-w>W",          desc = "back from ToggleTerm when Normal mode" },
    { mode = "i", "<C-k>", "<Esc><C-w>W" },
    { mode = "t", "<C-k>", "<C-Bslash><C-n><C-w>W" },
    -- { mode = 'n',  '',  ':', },
    -- { mode = 'i',  '',  '<Esc><C-o>:', },
    -- { mode = 't',  '',  '<C-Bslash><C-n><C-w>:', },
    -- { mode = 'n',  '',  '/', },
    -- { mode = 'i',  '',  '<Esc><C-o>/', },
    -- { mode = 't',  '',  '<C-Bslash><C-n>/', },
  },
  floaterm = {
    { "<Leader>fn",   ":FloatermNew<CR>",     desc = "Floaterm normal" },
    { "<Leader>flg",  ":FloatermNew lg<CR>",  desc = "Floaterm lazygit" },
    { "<Leader>flzd", ":FloatermNew lzd<CR>", desc = "Floaterm lazydocker" },
  },
  telescope = {
    { "<Leader>ff", function() require("telescope.builtin").find_files() end,                 desc = "Telescope find_files" },
    { "<Leader>fg", function() require("telescope.builtin").live_grep() end,                  desc = "Telescope live_grep" },
    { "<Leader>fb", function() require("telescope.builtin").buffers() end,                    desc = "Telescope buffers" },
    { "<Leader>fh", function() require("telescope.builtin").help_tags() end,                  desc = "Telescope help_tags" },
    { "<Leader>cb", function() require("telescope.builtin").current_buffer_fuzzy_find() end,  desc = "Telescope current_buffer_fuzzy_find" },
    { "<Leader>fm", function() require('telescope').extensions.media_files.media_files() end, desc = "Telescope media_files" },
    { "<Leader>cs", function() require("telescope.builtin").commands() end,                   desc = "Telescope commands" },
    { "<Leader>li", function() require("telescope.builtin").lsp_implementations() end,        desc = "Telescope implementations" },
    { "<F12>",      function() require("telescope.builtin").lsp_definitions() end,            desc = "Telescope difinitions" },
    { "gd",         function() require("telescope.builtin").lsp_definitions() end,            desc = "Telescope difinitions" },
    -- back is <C-o>
    { "<Leader>lt", function() require("telescope.builtin").lsp_type_definitions() end,       desc = "Telescope type_definitions" },
    { "<S-F12>",    function() require("telescope.builtin").lsp_references() end,             desc = "Telescope references" },
    { "<Leader>jl", function() require("telescope.builtin").jumplist() end,                   desc = "Telescope jumplist" },
    { "<Leader>b",  "<C-o>",                                                                  desc = "back jump list" },
  },
  lspsaga = {
    { mode = "n", "<Leader>ln", ":Lspsaga rename<CR>",      desc = "rename (lspsaga)" },
    { mode = "n", "<Leader>la", ":Lspsaga code_action<CR>", desc = "Code Action (lspsaga)" },
    { mode = "n", "<Leader>ls", ":Lspsaga finder<CR>",      desc = "Lsp Search (lspsaga)" },
  },
  common = {
    -- # zen mode
    { "<Leader>zm", ":ZenMode<CR>", desc = "Zen Mode" },
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
