--- https://qiita.com/delphinus/items/d07994f29550764bd8bc
local api = require("my")

local M = {}

local function get_config(name)
  return require(string.format("config.%s", name))
end

M.firenvim = {
  {
    "glacambre/firenvim",
    init = function()
      vim.fn["firenvim#install"](0)
    end,
    lazy = true,
  },
}
M.ordinalnvim = {
  -- self manage
  {
    "shortarrow/hanzen.nvim",
    config = function()
      require("hanzen").setup()
    end,
    dev = false,
  },
  -- { 'echasnovski/mini.nvim' },
  {
    "xiyaowong/transparent.nvim",
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({})
    end,
    keys = api.keymaps.maps.copilotchat,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  { "zbirenbaum/copilot.lua" }, -- for CopilotC-Nvim/CopilotChat.nvim
  { "nvim-lua/plenary.nvim" },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    -- dependencies = {
    --   { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
    --   { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    -- },
    cmd = "CopilotChat",
    event = "InsertEnter",
    opts = get_config("_copilot_chat").opts,
    -- See Commands section for default commands if you want to lazy load on them
  },
  -- {
  --   "github/copilot.vim",
  --   config = get_config("_copilot").setup,
  --   lazy = false,
  -- },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
  },
  {
    "echasnovski/mini.icons"
  },
  -- {
  --   "folke/snacks.nvim",
  --   priority = 1000,
  --   event = "VeryLazy",
  --   opts = get_config("_snacks").opts,
  --   keys = api.keymaps.maps.snacks,
  --   config = get_config("_snacks").config,
  -- },
  {
    "https://codeberg.org/esensar/nvim-dev-container",
    -- dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = {
      "DevcontainerStart",
      "DevcontainerAttach",
      "DevcontainerExec",
      "DevcontainerStop",
      "DevcontainerStopAll",
      "DevcontainerRemoveAll",
      "DevcontainerLogs",
      "DevcontainerEditNearestConfig",
    },
    config = get_config("_devcontainer").setup,
  },
  { "nvim-lua/plenary.nvim" },
  {
    "glacambre/firenvim",
    init = function()
      vim.fn["firenvim#install"](0)
    end,
    lazy = true,
    enabled = api.env.is_firenvim(),
  },
  -- ################################################
  -- # Color
  -- ################################################
  {
    "folke/tokyonight.nvim",
    config = get_config("_tokyonight").setup,
    event = "BufEnter",
  },
  { "RRethy/vim-illuminate" },
  {
    "folke/twilight.nvim",
    config = get_config("_twilight").setup,
  },
  {
    "uga-rosa/ccc.nvim",
    config = get_config("_ccc").setup,
    cmd = "CccPick",
  },
  -- ################################################
  -- # Fonts
  -- ################################################
  -- {
  --  'yamatsum/nvim-nonicons',
  --  dependencies = { 'nvim-tree/nvim-web-devicons' },
  --},
  {
    "uga-rosa/jam.nvim",
  },
  -- ################################################
  -- # Motion
  -- ################################################
  {
    "phaazon/hop.nvim",
    config = get_config("_hop").setup,
    keys = api.keymaps.maps.hop,
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = get_config("_surround").setup,
  },
  {
    "stevearc/aerial.nvim",
    enabled = false, -- Disabled due to Treesitter conflicts
    config = get_config("_aerial").setup,
    keys = api.keymaps.maps.aerial,
  },
  {
    "tversteeg/registers.nvim",
    config = get_config("_registers").setup,
  },
  {
    "jpalardy/vim-slime",
    config = get_config("_slime").setup,
  },
  -- ################################################
  -- # Explorer
  -- ################################################
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },
  { "obaland/vfiler-column-devicons" },
  {
    "obaland/vfiler.vim",
    -- dependencies = {
    --   "obaland/vfiler-column-devicons",
    --   "nvim-tree/nvim-web-devicons",
    -- },
    config = get_config("_vfiler").setup,
    keys = api.keymaps.maps.vfiler,
  },
  {
    "obaland/vfiler-patch-noice.nvim"
  },
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    -- dependencies = { "nvim-tree/nvim-web-devicons" },
    config = get_config("_fzflua").setup,
    enabled = not api.env.is_win_os(),
    keys = require("my.keymaps").maps.fzflua,
  },
  {
    "amirrezaask/fuzzy.nvim",
    -- dependencies = { "nvim-lua/plenary.nvim" },
    config = get_config("_fuzzy").setup,
    enabled = false,
  },
  -- ################################################
  -- # Trouble
  -- ################################################
  {
    "folke/trouble.nvim",
    -- dependencies = "nvim-tree/nvim-web-devicons",
    config = get_config("_trouble").setup,
    keys = api.keymaps.maps.trouble,
  },
  -- neotest
  { "nvim-neotest/neotest-python",    lazy = true },
  { "nvim-neotest/neotest-plenary",   lazy = true },
  { "nvim-neotest/neotest-vim-test",  lazy = true },
  { "marilari88/neotest-vitest",      lazy = true },
  { "haydenmeade/neotest-jest",       lazy = true },
  { "sidlatau/neotest-dart",          lazy = true },
  { "nvim-neotest/neotest-go",        lazy = true },
  { "rouge8/neotest-rust",            lazy = true },
  { "Issafalcon/neotest-dotnet",      lazy = true },
  { "MarkEmmons/neotest-deno",        lazy = true },
  { "antoinemadec/FixCursorHold.nvim" },
  { "nvim-neotest/nvim-nio",          lazy = true },
  {
    "nvim-neotest/neotest",
    -- dependencies = {
    --   "nvim-neotest/nvim-nio",
    --   "nvim-lua/plenary.nvim",
    --   "antoinemadec/FixCursorHold.nvim",
    --   "nvim-treesitter/nvim-treesitter",
    --   "nvim-neotest/neotest-python",
    --   "nvim-neotest/neotest-plenary",
    --   "nvim-neotest/neotest-vim-test",
    --   "marilari88/neotest-vitest",
    --   "haydenmeade/neotest-jest",
    --   "sidlatau/neotest-dart",
    --   "nvim-neotest/neotest-go",
    --   "rouge8/neotest-rust",
    --   "Issafalcon/neotest-dotnet",
    --   "MarkEmmons/neotest-deno",
    -- },
    config = get_config("_neotest").setup,
    keys = api.keymaps.maps.neotest,
  },
  -- ################################################
  -- # UI
  -- ################################################
  {
    "folke/zen-mode.nvim",
    opts = {
      plugins = {
        twilight = { enabled = false }, -- enable to start Twilight when zen mode opens
      },
    },
  },
  {
    "SmiteshP/nvim-gps",
    enabled = false, -- Requires Treesitter
    -- dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = get_config("_gps").setup,
  },
  {
    "lalitmee/browse.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = api.keymaps.maps.telescope,
  },
  {
    "simrat39/symbols-outline.nvim",
    config = get_config("_symbols_outline").setup,
  },
  {
    "gennaro-tedesco/nvim-peekup",
  },
  -- {
  --   "freddiehaddad/feline.nvim",
  --   require = { "nvim-lua/plenary.nvim", "lewis6991/gitsigns.nvim" },
  --   config = get_config("_feline").setup,
  --   enabled = not api.env.is_firenvim(),
  -- },
  {
    "stevearc/overseer.nvim",
    version = "v1.6.0",
  },
  {
    "rebelot/heirline.nvim",
    dependencies = {
      "Zeioth/heirline-components.nvim",
      "lewis6991/gitsigns.nvim",
      "zeioth/compiler.nvim",
      "linux-cultist/venv-selector.nvim",
      "nvim-neo-tree/neo-tree.nvim",
      "stevearc/aerial.nvim",
    },
    opts = get_config("_heirline").opts,
    config = get_config("_heirline").config,
    event = "BufEnter",
  },
  -- { "lewis6991/gitsigns.nvim" },
  -- { "nvim-telescope/telescope.nvim" },
  { "zeioth/compiler.nvim" },
  { "mfussenegger/nvim-dap" },
  { "echasnovski/mini.bufremove" },
  { "nvim-neo-tree/neo-tree.nvim" },
  -- { "stevearc/aerial.nvim" },
  -- { "folke/zen-mode.nvim" },
  { "linux-cultist/venv-selector.nvim" },
  { "echasnovski/mini.nvim" },
  -- {
  --   "akinsho/bufferline.nvim",
  --   version = "*",
  --   dependencies = {
  --     -- "nvim-tree/nvim-web-devicons",
  --   },
  --   config = get_config("_buffer_line").setup,
  -- },
  { "nvim-tree/nvim-web-devicons" },
  {
    "b0o/incline.nvim",
    config = get_config("_incline").setup,
    enabled = not api.env.is_firenvim(),
  },
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    keys = api.keymaps.maps.diffview,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "folke/trouble.nvim",
      "nvim-lua/plenary.nvim", --[[ 'akinsho/flutter-tools.nvim'  ]]
    },
    config = get_config("_telescope").setup,
    event = { "BufRead", "CmdlineEnter" },
  },
  {
    "nvim-telescope/telescope-media-files.nvim",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    after = "telescope.nvim",
    config = get_config("_telescope_media_files").setup,
    event = "BufRead"
  },
  {
    "folke/which-key.nvim",
    config = get_config("_whichkey").setup,
    keys = api.keymaps.maps.whichkey,
    lazy = true,
  },
  {
    "voldikss/vim-floaterm",
    keys = api.keymaps.maps.floaterm,
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = get_config("_toggleterm").setup,
    keys = api.keymaps.maps.toggleterm,
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
      -- "nvim-treesitter/nvim-treesitter",
    },
    config = get_config("_ufo").setup,
    keys = api.keymaps.maps.ufo,
  },
  --{
  --  'edluffy/specs.nvim',
  --  config = get_config('_specs').setup,
  --},
  -- {
  --   "folke/noice.nvim",
  --   priority = 1001,
  --   event = "VeryLazy",
  --   config = get_config("_noice").setup,
  --   dependencies = {
  --     -- if you lazy-load any plugin below, make sure to add proper `module='...'` entries
  --     "MunifTanjim/nui.nvim",
  --     -- OPTIONAL:
  --     --   `nvim-notify` is only needed, if you want to use the notification view.
  --     --   If not available, we use `mini` as the fallback
  --     "rcarriga/nvim-notify",
  --   },
  -- },
  {
    "rcarriga/nvim-dap-ui",
    -- dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  },
  { "nvim-neotest/nvim-nio",    lazy = true },
  --{
  --  'yamatsum/nvim-cursorline',
  --  config = get_config('_cursorline').setup,
  --},
  -- ################################################
  -- Markdown
  -- ################################################
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      -- add options here
      -- or leave it empty to use the default settings
    },
    keys = {
      -- suggested keymap
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },
  {
    'MeanderingProgrammer/markdown.nvim',
    main = "render-markdown",
    event = "BufRead",
    opts = {},
    name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  },
  -- ################################################
  -- # Flutter
  -- ################################################
  {
    "akinsho/flutter-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      "stevearc/dressing.nvim",
    },
    after = "telescope.nvim",
    config = get_config("_flutter").setup,
    keys = api.keymaps.maps.flutter,
  },
  -- ################################################
  -- # Dart
  -- ################################################
  { "dart-lang/dart-vim-plugin" },
  { "natebosch/vim-lsc" },
  { "natebosch/vim-lsc-dart" },
  { "lervag/vimtex",            lazy = true }, -- Use braces when passing options
  -- ################################################
  -- # Rust
  -- ################################################
  {
    "simrat39/rust-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig", "mfussenegger/nvim-dap" },
    ft = { "rust" },
    enabled = false, -- disabled to avoid deprecated lspconfig framework usage
    -- config = get_config("_rust").setup,
    -- keys = api.keymaps.maps.rust_tools,
  },
  {
    "alaviss/nim.nvim",
  },
  -- ################################################
  -- # Lua
  -- ################################################
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim",        words = { "Snacks" } },
        { path = "lazy.nvim",          words = { "LazyVim" } },
        "nvim-dap-ui",
      },
    },
  },
  -- Install this plugin.
  { "tjdevries/nlua.nvim" },
  -- (OPTIONAL): This is recommended to get better auto-completion UX experience for builtin LSP.
  -- {"nvim-lua/completion-nvim"},
  -- (OPTIONAL): This is a suggested plugin to get better Lua syntax highlighting
  --   but it's not currently required
  { "euclidianAce/BetterLua.vim" },
  -- (OPTIONAL): If you wish to have fancy lua folds, you can check this out.
  { "tjdevries/manillua.nvim" },
  -- ################################################
  -- # Git
  -- ################################################
  {
    "lewis6991/gitsigns.nvim",
    config = get_config("_gitsigns").setup,
    event = "BufRead",
  },
  {
    "tpope/vim-fugitive",
    config = get_config("_fugitive").setup,
    keys = api.keymaps.maps.fugitive,
  },
  {
    "TimUntersberger/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    config = get_config("_neogit").setup,
    keys = api.keymaps.maps.neogit,
  },
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = get_config("_octo").setup,
    cmd = "Octo",
  },
  {
    "kdheepak/lazygit.nvim",
    keys = api.keymaps.maps.lazygit,
    cmd = "LazyGit",
  },
  -- ################################################
  -- # Indent and Bracket
  -- ################################################
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    config = get_config("_indent").setup,
  },
  -- ################################################
  -- # Comment
  -- ################################################
  {
    "numToStr/Comment.nvim",
    config = get_config("_comment").setup,
  },
  -- ################################################
  -- # LSP
  -- ################################################
  -- {
  --   "vim-skk/skkeleton",
  --   dependencies = { "vim-denops/denops.vim" },
  -- },
  {
    "mfussenegger/nvim-lint",
    config = get_config("_lint").setup,
  },
  {
    "rafamadriz/friendly-snippets",
  },
  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!)
    build = "make install_jsregexp",
    config = get_config("_luasnip").setup,
    event = { "InsertEnter", "CmdlineEnter" }
  },
  --  {
  --    "L3MON4D3/LuaSnip",
  --    config = get_config("_luasnip").setup,
  --  },
  --  {
  --    "saadparwaiz1/cmp_luasnip",
  --    dependencies = "L3MON4D3/LuaSnip",
  --  },
  { "hrsh7th/cmp-nvim-lsp" },
  {
    "williamboman/mason.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "jayp0521/mason-nvim-dap.nvim",
      "jayp0521/mason-null-ls.nvim",
    },
    config = function()
      require("config._mason").setup()
      require("config._mason_lspconfig").setup()
      require("config._mason_installer").setup()
      require("config._mason_nvim_dap").setup()
      require("config._mason_null_ls").setup()
    end,
    event = { "BufReadPre", "CmdlineEnter" }
  },
  {
    "ray-x/lsp_signature.nvim",
    config = get_config("_lsp_sig").setup,
  },
  {
    "onsails/lspkind.nvim",
    config = get_config("_lsp_kind").setup,
  },
  {
    "weilbith/nvim-code-action-menu",
    cmd = "CodeActionMenu",
  },
  {
    "glepnir/lspsaga.nvim",
    -- dependencies = {
    --   "nvim-treesitter/nvim-treesitter", -- optional
    --   "nvim-tree/nvim-web-devicons", -- optional
    -- },
    cmd = "Lspsaga",
    config = get_config("_lsp_saga").setup,
    keys = api.keymaps.maps.lspsaga,
  },
  -- ################################################
  -- # Auto Complete
  -- ################################################
  {
    "nvim-treesitter/nvim-treesitter-context",
    enabled = false, -- Disabled until Treesitter stabilizes
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to show for a single context
        trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20, -- The Z-index of the context window
        on_attach = function(bufnr)
          -- Disable for special buffer types
          local ok_buftype, buftype = pcall(vim.api.nvim_buf_get_option, bufnr, 'buftype')
          local ok_filetype, filetype = pcall(vim.api.nvim_buf_get_option, bufnr, 'filetype')
          if (ok_buftype and buftype ~= '') or (ok_filetype and filetype == 'lazy') then
            return false
          end
          return true
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = true, -- Re-enabled
    build = ":TSUpdate",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      { "nvim-treesitter/nvim-treesitter-refactor", enabled = false },
      -- "windwp/nvim-ts-autotag",
      { "p00f/nvim-ts-rainbow", enabled = false },
    },
    -- init = function()
    --   require("nvim-treesitter.install").update({ with_sync = true })
    -- end,
    config = get_config("_treesitter").setup,
    event = "BufRead",
  },
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
    -- dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "InsertEnter"
  },
  {
    "KadoBOT/cmp-plugins",
    after = "nvim-cmp",
    config = get_config("_cmp_plugins").setup,
    event = { "InsertEnter", "CmdlineEnter" },
  },
  { "teramako/cmp-cmdline-prompt.nvim", lazy = true },
  { "chrisgrieser/cmp-nerdfont",        lazy = true },
  { "f3fora/cmp-spell",                 lazy = true },
  -- { "hrsh7th/cmp-buffer",                  lazy = true },
  -- { "hrsh7th/cmp-calc",                    lazy = true },
  -- { "hrsh7th/cmp-cmdline",                 lazy = true },
  -- { "hrsh7th/cmp-emoji",                   lazy = true },
  -- { "hrsh7th/cmp-path",                    lazy = true },
  -- { "hrsh7th/cmp-nvim-lsp",                lazy = true },
  -- { "hrsh7th/cmp-nvim-lsp-signature-help", lazy = true },
  -- { "hrsh7th/cmp-nvim-lua",                lazy = true },
  { "jc-doyle/cmp-pandoc-references",   lazy = true },
  { "KadoBOT/cmp-plugins",              lazy = true },
  { "octaltree/cmp-look",               lazy = true },
  { "ray-x/cmp-treesitter",             lazy = true },
  { "windwp/nvim-autopairs",            lazy = true },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      -- "chrisgrieser/cmp-nerdfont",
      -- "f3fora/cmp-spell",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua",
      -- "hrsh7th/cmp-vsnip",
      -- "hrsh7th/vim-vsnip",
      -- "hrsh7th/vim-vsnip-integ",
      -- "jc-doyle/cmp-pandoc-references",
      -- "KadoBOT/cmp-plugins",
      -- "octaltree/cmp-look",
      -- "ray-x/cmp-treesitter",
      -- "windwp/nvim-autopairs",
    },
    event = { "InsertEnter", "CmdlineEnter" },
    config = get_config("_cmp").setup,
  },
  {
    "windwp/nvim-autopairs",
    -- dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = get_config("_autopairs").setup,
  },
  {
    "nvimtools/none-ls.nvim",
    -- dependencies = { "nvim-lua/plenary.nvim" },
    config = get_config("_null_ls").setup,
    event = { "BufReadPre", "CmdlineEnter" }
  },
  {
    "hat0uma/csvview.nvim",
    ---@module "csvview"
    ---@type CsvView.Options
    opts = {
      parser = { comments = { "#", "//" } },
      keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        -- Excel-like navigation:
        -- Use <Tab> and <S-Tab> to move horizontally between fields.
        -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
        -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
      },
    },
    cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
  },
  {
    "alec-gibson/nvim-tetris",
  },
}

return M
