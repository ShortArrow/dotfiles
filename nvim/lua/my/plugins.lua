local api = require('my')

local M = {}

local function get_config(name)
  return require(string.format('config.%s', name))
end

M.firenvim = {
    {
        'glacambre/firenvim',
        init = function() vim.fn['firenvim#install'](0) end,
        lazy = true,
    },
}
M.ordinalnvim = {
    -- self manage
    { "lewis6991/impatient.nvim" },
    { "nvim-lua/plenary.nvim" },
    {
        'glacambre/firenvim',
        init = function() vim.fn['firenvim#install'](0) end,
        lazy = true,
        enabled = api.env.is_firenvim(),
    },
    -- ################################################
    -- # Color
    -- ################################################
    {
        'folke/tokyonight.nvim',
        config = get_config('_tokyonight').setup,
    },
    { 'RRethy/vim-illuminate' },
    {
        "folke/twilight.nvim",
        config = get_config('_twilight').setup,
    },
    -- ################################################
    -- # Fonts
    -- ################################################
    -- {
    --  'yamatsum/nvim-nonicons',
    --  dependencies = { 'kyazdani42/nvim-web-devicons' },
    --},
    {
        'uga-rosa/jam.nvim'
    },
    -- ################################################
    -- # Motion
    -- ################################################
    {
        'phaazon/hop.nvim',
        config = get_config('_hop').setup,
        keys = api.keymaps.maps.hop,
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = get_config('_surround').setup,
    },
    {
        'stevearc/aerial.nvim',
        config = get_config('_aerial').setup,
        keys = api.keymaps.maps.aerial,
    },
    {
        "tversteeg/registers.nvim",
        config = get_config('_registers').setup,
    },
    {
        'jpalardy/vim-slime',
        config = get_config('_slime').setup,
    },
    -- ################################################
    -- # Explorer
    -- ################################################
    {
        'obaland/vfiler.vim',
        dependencies = { 'obaland/vfiler-column-devicons', 'kyazdani42/nvim-web-devicons' },
        config = get_config('_vfiler').setup,
        keys = api.keymaps.maps.vfiler,
    },
    {
        'ibhagwan/fzf-lua',
        -- optional for icon support
        dependencies = { 'kyazdani42/nvim-web-devicons' },
        config = get_config('_fzflua').setup,
        enabled = not api.env.is_win_os(),
        keys = require("my.keymaps").maps.fzflua,
    },
    {
        'amirrezaask/fuzzy.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = get_config('_fuzzy').setup,
        enabled = false,
    },
    -- ################################################
    -- # Trouble
    -- ################################################
    {
        "folke/trouble.nvim",
        dependencies = "kyazdani42/nvim-web-devicons",
        config = get_config('_trouble').setup,
        keys = api.keymaps.maps.trouble,
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim",
            'nvim-neotest/neotest-python',
            'nvim-neotest/neotest-plenary',
            'nvim-neotest/neotest-vim-test',
            'marilari88/neotest-vitest',
            'haydenmeade/neotest-jest',
            'sidlatau/neotest-dart',
            'nvim-neotest/neotest-go',
            'rouge8/neotest-rust',
            'Issafalcon/neotest-dotnet',
            'MarkEmmons/neotest-deno',
        },
        config = get_config('_neotest').setup,
        keys = api.keymaps.maps.neotest,
    },
    -- ################################################
    -- # UI
    -- ################################################
    {
        "SmiteshP/nvim-gps",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = get_config("_gps").setup,
    },
    {
        "lalitmee/browse.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
    },
    {
        'simrat39/symbols-outline.nvim',
        config = get_config('_symbols_outline').setup,
    },
    {
        "gennaro-tedesco/nvim-peekup",
    },
    {
        'feline-nvim/feline.nvim',
        require = { 'nvim-lua/plenary.nvim', 'lewis6991/gitsigns.nvim' },
        config = get_config('_feline').setup,
        enabled = not api.env.is_firenvim(),
    },
    {
        'akinsho/bufferline.nvim',
        version = "v2.*",
        dependencies = {
            'kyazdani42/nvim-web-devicons'
        },
        config = get_config('_buffer_line').setup,
    },
    {
        'b0o/incline.nvim',
        config = get_config('_incline').setup,
        enabled = not api.env.is_firenvim(),
    },
    {
        'sindrets/diffview.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
        keys = api.keymaps.maps.diffview,
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'folke/trouble.nvim', 'nvim-lua/plenary.nvim',--[[ 'akinsho/flutter-tools.nvim'  ]] },
        config = get_config('_telescope').setup,
    },
    {
        'folke/which-key.nvim',
        config = get_config('_whichkey').setup,
        keys = api.keymaps.maps.whichkey,
    },
    {
        "voldikss/vim-floaterm",
        keys = api.keymaps.maps.floaterm,
    },
    {
        'akinsho/toggleterm.nvim',
        version = '*',
        config = get_config('_toggleterm').setup,
        keys = api.keymaps.maps.toggleterm,
    },
    {
        'kevinhwang91/nvim-ufo',
        dependencies = {
            'kevinhwang91/promise-async',
            'nvim-treesitter/nvim-treesitter'
        },
        config = get_config('_ufo').setup,
        keys = api.keymaps.maps.ufo,
    },
    --{
    --  'edluffy/specs.nvim',
    --  config = get_config('_specs').setup,
    --},
    {
        'folke/noice.nvim',
        config = get_config('_noice').setup,
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module='...'` entries
            'MunifTanjim/nui.nvim',
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            'rcarriga/nvim-notify',
        },
    },
    --{
    --  'yamatsum/nvim-cursorline',
    --  config = get_config('_cursorline').setup,
    --},
    -- ################################################
    -- # Flutter
    -- ################################################
    {
        'akinsho/flutter-tools.nvim',
        dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig', 'mfussenegger/nvim-dap' },
        config = get_config('_flutter').setup,
        keys = api.keymaps.maps.flutter,
    },
    -- ################################################
    -- # Dart
    -- ################################################
    { "dart-lang/dart-vim-plugin" },
    { "natebosch/vim-lsc" },
    { "natebosch/vim-lsc-dart" },
    { "jiangmiao/auto-pairs" },
    { 'lervag/vimtex',            lazy = true }, -- Use braces when passing options
    -- ################################################
    -- # Rust
    -- ################################################
    {
        'simrat39/rust-tools.nvim',
        dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig', 'mfussenegger/nvim-dap' },
        config = get_config('_rust').setup,
    },
    {
      'alaviss/nim.nvim',
    },
    -- ################################################
    -- # Lua
    -- ################################################
    {
        "folke/neodev.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
        },
        config = get_config('_neodev').setup,
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
        'lewis6991/gitsigns.nvim',
        config = get_config('_gitsigns').setup,
    },
    {
        'tpope/vim-fugitive',
        config = get_config('_fugitive').setup,
        keys = api.keymaps.maps.fugitive,
    },
    {
        'TimUntersberger/neogit',
        dependencies = 'nvim-lua/plenary.nvim',
        keys = api.keymaps.maps.neogit,
    },
    {
        'pwntester/octo.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim',
            'kyazdani42/nvim-web-devicons',
        },
        config = get_config('_octo').setup,
        cmd = "Octo",
    },
    {
        'kdheepak/lazygit.nvim',
        keys = api.keymaps.maps.lazygit,
        cmd = "LazyGit",
    },
    -- ################################################
    -- # Indent and Bracket
    -- ################################################
    {
        "lukas-reineke/indent-blankline.nvim",
        config = get_config('_indent').setup,
    },
    -- ################################################
    -- # Comment
    -- ################################################
    {
        'numToStr/Comment.nvim',
        config = get_config('_comment').setup,
    },
    -- ################################################
    -- # LSP
    -- ################################################
    {
        "vim-skk/skkeleton",
        dependencies = { "vim-denops/denops.vim" },
    },
    {
        'mfussenegger/nvim-lint',
        config = get_config('_lint').setup,
    },
    {
        "rafamadriz/friendly-snippets"
    },
    {
        "L3MON4D3/LuaSnip",
        config = get_config('_luasnip').setup,
    },
    {
        "saadparwaiz1/cmp_luasnip",
        dependencies = "L3MON4D3/LuaSnip",
    },
    {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
        "jayp0521/mason-null-ls.nvim",
        "jayp0521/mason-nvim-dap.nvim",
        dependencies = {
            "jose-elias-alvarez/null-ls.nvim",
            "mfussenegger/nvim-dap",
            'ray-x/lsp_signature.nvim',
            'hrsh7th/cmp-nvim-lsp',
            'onsails/lspkind.nvim',
            'kevinhwang91/nvim-ufo',
        },
        config = get_config('_mason').setup,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        config = get_config("_mason_installer").setup,
    },
    {
        "ray-x/lsp_signature.nvim",
        config = get_config('_lsp_sig').setup,
    },
    {
        'onsails/lspkind.nvim',
        config = get_config('_lsp_kind').setup,
    },
    {
        'weilbith/nvim-code-action-menu',
        cmd = 'CodeActionMenu',
    },
    {
        "glepnir/lspsaga.nvim",
        branch = "main",
        config = get_config('_lsp_saga').setup,
        keys = api.keymaps.maps.lspsaga,
    },
    -- ################################################
    -- # Auto Complete
    -- ################################################
    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'JoosepAlviste/nvim-ts-context-commentstring',
            'windwp/nvim-ts-autotag',
            'nvim-treesitter/nvim-treesitter-refactor',
            'nvim-treesitter/nvim-treesitter-context',
            'windwp/nvim-ts-autotag',
            'p00f/nvim-ts-rainbow',
        },
        init = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
        config = get_config('_treesitter').setup,
    },
    {
        'KadoBOT/cmp-plugins',
        config = get_config('_cmp_plugins').setup,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            'chrisgrieser/cmp-nerdfont',
            'f3fora/cmp-spell',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-calc',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-emoji',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-nvim-lua',
            -- "hrsh7th/cmp-vsnip",
            -- "hrsh7th/vim-vsnip",
            -- "hrsh7th/vim-vsnip-integ",
            'jc-doyle/cmp-pandoc-references',
            'KadoBOT/cmp-plugins',
            'octaltree/cmp-look',
            'ray-x/cmp-treesitter',
        },
        config = get_config('_cmp').setup,
    },
    {
        'jose-elias-alvarez/null-ls.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = get_config('_null_ls').setup,
    },
    {
        'alec-gibson/nvim-tetris'
    },
}

return M
