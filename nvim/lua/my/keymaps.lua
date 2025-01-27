local M = {}

local telescope = require("config/_telescope").commands
local neotest = require("config/_neotest").commands

M.maps_activate = function(map)
  for _, item in pairs(map) do
    local mode = item.mode or "n"
    vim.keymap.set(mode, item[1], item[2], {
      -- noremap: true
      -- silent: false
      -- script: false
      -- expr: false
      -- buffer: nil
      -- nowait: false
    })
  end
end

M.commonmaps_activate = function()
  M.maps_activate(M.maps.common)
end

M.vscode_map_activate = function()
  M.maps_activate(M.maps.vscode)
end

M.maps = {
  aerial = {
    { "{", "<cmd>AerialPrev<CR>" },
    { "}", "<cmd>AerialNext<CR>" },
    -- vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
    -- vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
  },
  copilotchat = {
    { mode = { "n", "v" }, "<Leader>cc", "<cmd>CopilotChat<CR>" },
  },
  lazygit = {
    { "<Leader>lg", "<cmd>LazyGit<CR>" },
  },
  rust_tools = {
    {
      mode = "n",
      "K",
      function()
        require("rust-tools.hover_actions").hover_actions()
      end,
      desc = "Rust Hover",
    },
    {
      mode = "n",
      "<Leader>ca",
      function()
        require("rust-tools.code_action_group").code_action_group()
      end,
      desc = "Rust Code Action Group",
    },
  },
  neotest = {
    { "gtr", neotest.run,     desc = "NeoTest nearest run" },
    { "gtt", neotest.toggle,  desc = "NeoTest Open" },
    { "gtc", neotest.current, desc = "NeoTest current run" },
    { "gtd", neotest.dap,     desc = "NeoTest dap run" },
  },
  neogit = {
    {
      "<Leader>ng",
      function()
        require("neogit").open()
      end,
    },
  },
  ufo = {
    {
      "zR",
      function()
        require("ufo").openAllFolds()
      end,
    },
    {
      "zM",
      function()
        require("ufo").closeAllFolds()
      end,
    },
  },
  hop = {
    { "<Leader>hw", "<cmd>HopWord<CR>" },
    { "<Leader>hl", "<cmd>HopLine<CR>" },
    { "<Leader>hp", "<cmd>HopPattern<CR>" },
  },
  fugitive = {
    { "<Leader>ga",  "keymap" },
    { "<Leader>ga",  "<cmd>Git add .<CR>" },
    { "<Leader>gb",  "<cmd>Git blame<CR>" },
    { "<Leader>gc",  ":Git commit -m " },
    { "<Leader>gd",  "<cmd>Gvdiffsplit<CR>" },
    { "<Leader>gll", "<cmd>Gllog<CR>" },
    { "<Leader>glc", "<cmd>Gclog<CR>" },
    { "<Leader>gp",  "<cmd>Git push<CR>" },
    { "<Leader>gs",  "<cmd>Git status<CR>" },
  },
  diffview = {
    { "<Leader>dvh", "<cmd>DiffviewFileHistory<CR>" },
    { "<Leader>dvc", "<cmd>DiffviewClose<CR>" },
    { "<Leader>dvt", "<cmd>DiffviewToggleFiles<CR>" },
    { "<Leader>dvf", "<cmd>DiffviewFocusFiles<CR>" },
    { "<Leader>dvr", "<cmd>DiffviewRefresh<CR>" },
    { "<Leader>dvo", "<cmd>DiffviewOpen<CR>" },
  },
  whichkey = {
    { "<Leader>km", "<cmd>WhichKey<CR>" },
  },
  flutter = {
    { "<Leader>fr", "<cmd>FlutterRun -d web-server<CR>", desc = "Flutter Run" },
    { "<Leader>fc", telescope.flutter_commands,          desc = "Flutter Open" },
  },
  trouble = {
    { "<Leader>tr", "<cmd>Trouble diagnostics<CR>" },
  },
  fzflua = {
    { "<Leader>zf", "<cmd>FzfLua files<CR>" },
  },
  packer = {
    {
      mode = "n",
      "<Leader>ps",
      function()
        require("packer").sync()
      end,
    },
  },
  snacks =
  {
    { "<leader>ps", function() Snacks.profiler.scratch() end,      desc = "Profiler Scratch Bufer" },
    { "<leader>.",  function() Snacks.scratch() end,               desc = "Toggle Scratch Buffer" },
    { "<leader>S",  function() Snacks.scratch.select() end,        desc = "Select Scratch Buffer" },
    { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>bd", function() Snacks.bufdelete() end,             desc = "Delete Buffer" },
    { "<leader>cR", function() Snacks.rename.rename_file() end,    desc = "Rename File" },
    { "<leader>gB", function() Snacks.gitbrowse() end,             desc = "Git Browse" },
    { "<leader>gb", function() Snacks.git.blame_line() end,        desc = "Git Blame Line" },
    { "<leader>gf", function() Snacks.lazygit.log_file() end,      desc = "Lazygit Current File History" },
    { "<leader>gg", function() Snacks.lazygit() end,               desc = "Lazygit" },
    { "<leader>gl", function() Snacks.lazygit.log() end,           desc = "Lazygit Log (cwd)" },
    { "<leader>un", function() Snacks.notifier.hide() end,         desc = "Dismiss All Notifications" },
    { "<c-/>",      function() Snacks.terminal() end,              desc = "Toggle Terminal" },
    { "<c-_>",      function() Snacks.terminal() end,              desc = "which_key_ignore" },
    {
      "]]",
      function() Snacks.words.jump(vim.v.count1) end,
      desc = "Next Reference",
      mode = {
        "n", "t" }
    },
    {
      "[[",
      function() Snacks.words.jump(-vim.v.count1) end,
      desc = "Prev Reference",
      mode = {
        "n", "t" }
    },
    {
      "<leader>N",
      desc = "Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.9,
          height = 0.9,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    }
  },
  vfiler = {
    { "<Leader>vf", "<cmd>VFiler<CR>" },
  },
  toggleterm = {
    {
      "<Leader>tt",
      function()
        require("config/_toggleterm").toggle_repl_term()
      end,
      desc = "ToggleTerm normal",
    },
    { mode = "n", "<C-k>", "<C-w><C-w>W",           desc = "back from ToggleTerm when Normal mode" },
    { mode = "i", "<C-k>", "<Esc><C-w>W",           desc = "back from ToggleTerm when Normal mode" },
    { mode = "t", "<C-k>", "<C-Bslash><C-n><C-w>W", desc = "back from ToggleTerm when Normal mode" },
    -- { mode = 'n',  '',  ':', },
    -- { mode = 'i',  '',  '<Esc><C-o>:', },
    -- { mode = 't',  '',  '<C-Bslash><C-n><C-w>:', },
    -- { mode = 'n',  '',  '/', },
    -- { mode = 'i',  '',  '<Esc><C-o>/', },
    -- { mode = 't',  '',  '<C-Bslash><C-n>/', },
  },
  floaterm = {
    { "<Leader>fn",   "<cmd>FloatermNew<CR>",     desc = "Floaterm normal" },
    { "<Leader>flg",  "<cmd>FloatermNew lg<CR>",  desc = "Floaterm lazygit" },
    { "<Leader>flzd", "<cmd>FloatermNew lzd<CR>", desc = "Floaterm lazydocker" },
  },
  telescope = {
    { "<Leader>ff", telescope.find_files,                desc = "Telescope find_files" },
    { "<Leader>fg", telescope.live_grep,                 desc = "Telescope live_grep" },
    { "<Leader>fb", telescope.buffers,                   desc = "Telescope buffers" },
    { "<Leader>fh", telescope.help_tags,                 desc = "Telescope help_tags" },
    { "<Leader>fl", telescope.current_buffer_fuzzy_find, desc = "Telescope current_buffer_fuzzy_find" },
    { "<Leader>fm", telescope.media_files,               desc = "Telescope media_files" },
    { "<Leader>cs", telescope.commands,                  desc = "Telescope commands" },
    { "<Leader>li", telescope.lsp_implementations,       desc = "Telescope implementations" },
    { "<F12>",      telescope.lsp_definitions,           desc = "Telescope difinitions" },
    { "gd",         telescope.lsp_definitions,           desc = "Telescope difinitions" },
    { "<Leader>lt", telescope.lsp_type_definitions,      desc = "Telescope type_definitions" },
    { "<S-F12>",    telescope.lsp_references,            desc = "Telescope references" },
    { "<Leader>jl", telescope.jump_list,                 desc = "Telescope jumplist" },
    { "<Leader>lb", "<C-o>",                             desc = "back jump list" },
  },
  lspsaga = {
    { "<Leader>ln", "<cmd>Lspsaga rename<CR>",          desc = "rename (lspsaga)" },
    { "<F2>",       "<cmd>Lspsaga rename<CR>",          desc = "rename (lspsaga)" },
    { "<Leader>la", "<cmd>Lspsaga code_action<CR>",     desc = "Code Action (lspsaga)" },
    { "<Leader>ld", "<cmd>Lspsaga goto_definition<CR>", desc = "Goto definition(lspsaga)" },
    -- { mode = "n", "<Leader>lt", "<cmd>Lspsaga goto_type_definition<CR>", desc = "Goto type definition(lspsaga)" },
    {
      mode = "n",
      "<Leader>ls",
      "<cmd>Lspsaga finder<CR>",
      desc = "Lsp Search (lspsaga)",
    },
    {
      mode = "n",
      "<F8>",
      "<cmd>Lspsaga diagnostic_jump_next<CR>",
      desc = "Lsp diagnostic_jump_next(lspsaga)",
    },
    {
      mode = "n",
      "<S-F8>",
      "<cmd>Lspsaga diagnostic_jump_prev<CR>",
      desc = "Lsp diagnostic_jump_prev(lspsaga)",
    },
  },
  common = {
    -- # Dap
    { "<Leader>dc", "<cmd>lua require('dap').continue()<CR>", desc = "Dap Continue" },
    { "<Leader>dr", "<cmd>lua require('dap').repl.open()<CR>", desc = "Dap Repl" },
    { "<Leader>ds", "<cmd>lua require('dap').step_over()<CR>", desc = "Dap Step Over" },
    { "<Leader>di", "<cmd>lua require('dap').step_into()<CR>", desc = "Dap Step Into" },
    { "<Leader>do", "<cmd>lua require('dap').step_out()<CR>", desc = "Dap Step Out" },
    { "<Leader>db", "<cmd>lua require('dap').toggle_breakpoint()<CR>", desc = "Dap Toggle Breakpoint" },
    { "<Leader>du", "<cmd>lua require('dapui').setup(); require('dapui').open()<CR>", desc = "Dap UI Open" },
    { "<Leader>dl", "<cmd>lua require('dap').run_last()<CR>", desc = "Dap Run Last" },
    -- # noice dismiss
    { "<Leader><Esc>", "<cmd>NoiceDismiss<CR>", desc = "dismiss noice error and escape" },
    -- # zen mode
    { "<Leader>zm", "<cmd>ZenMode<CR>", desc = "Zen Mode" },
    -- # lsp keymaps
    { "<Leader>lk", vim.lsp.buf.hover, desc = "show references (Lsp References)" },
    -- { "<Leader>ld", vim.lsp.buf.definition, desc = "jump to definition (Lsp Definition)" },
    { "<Leader>lf", vim.lsp.buf.format, desc = "auto formatting (Lsp Formatting)" },
    -- { "<A-S-F>",      vim.lsp.buf.format,     desc = "auto formatting (Lsp Formatting)" },
    { "<Leader>lr", vim.lsp.buf.references, desc = "show references (Lsp References)" },
    -- rename (Lsp Name)
    -- {  '<Leader>ln',  '<cmd>lua vim.lsp.buf.rename()<CR>', },
    -- code_action (Lsp Action)
    -- {  '<Leader>la',  '<cmd>lua vim.lsp.buf.code_action()<CR>', },

    -- # window keymaps
    { "<Leader>wp", "<C-w>p", desc = "go to previous window (Window Previous)" },
    { "<Leader>wl", "<C-w>l", desc = "right (Window L)" },
    { "<Leader>wh", "<C-w>h", desc = "left (Window H)" },
    { "<Leader>wj", "<C-w>j", desc = "down (Window J)" },
    { "<Leader>wk", "<C-w>k", desc = "up (Window K)" },

    -- # buffer keymaps
    { "<Leader>bp", "<cmd>bprevious<CR>", desc = "go to previous buffer (Buffer Previous)" },
    { "<Leader>bn", "<cmd>bnext<CR>", desc = "go to next buffer (Buffer Next)" },

    -- # japanese keymaps
    { "<Down>", "gj", desc = "IME safe of あ" },
    { "<Up>", "gk", desc = "IME safe of あ" },
    { "あ", "a", desc = "IME safe of あ" },
    { "い", "i", desc = "IME safe of い" },
    { "う", "u", desc = "IME safe of う" },
    { "お", "o", desc = "IME safe of お" },
    { "っd", "dd", desc = "IME safe of dd" },
    { "ｄｄ", "dd", desc = "IME safe of dd" },
    { "っy", "yy", desc = "IME safe of yy" },
    { "ｙｙ", "yy", desc = "IME safe of yy" },
    { "ｊｊ", "<Esc>", desc = "IME safe of jj" },
    { "ｊ", "<Down>", desc = "IME safe of j" },
    { "ｋ", "<Up>", desc = "IME safe of k" },
    { 'し"', 'ci"', desc = "IME safe of ci" },
    { "し'", "ci'", desc = "IME safe of ci" },
    { "し”", 'ci"', desc = "IME safe of ci" },
    { "し’", "ci'", desc = "IME safe of ci" },
    { "：ｗ", "<cmd>w<CR>", desc = "IME safe of :w" },
    { "：ｗｑ", "<cmd>wq<CR>", desc = "IME safe of :wq" },
    { "：ｑ", "<cmd>q<CR>", desc = "IME safe of :w" },
    { "：くぁ", "<cmd>qa<CR>", desc = "IME safe of :w" },
    -- { mode = 'n', '<C-S-h>', '<Left>', desc = "IME safe of <Left>" },
    -- { mode = 'n', '<C-S-j>', '<Down>', desc = "IME safe of <Down>" },
    -- { mode = 'n', '<C-S-k>', '<Up>', desc = "IME safe of <Up>" },
    -- { mode = 'n', '<C-S-l>', '<Right>', desc = "IME safe of <Right>" },

    { mode = "i", "jj", "<Esc>", desc = "Escape with jj" },
    -- # help keymaps
    { "<Leader>?", "<cmd>h quickref<CR>" },
  },
}

return M
