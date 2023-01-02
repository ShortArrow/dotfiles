local api = require('my.api')

local M = {}

local function get_config(name)
  return require(string.format('config.%s', name))
end

M.firenvim = {
  {
    'glacambre/firenvim',
    run = function() vim.fn['firenvim#install'](0) end
  },
}
M.ordinalnvim = {
  -- self manage
  { "wbthomason/packer.nvim" },
  { "lewis6991/impatient.nvim" },
  { "nvim-lua/plenary.nvim" },
  {
    'glacambre/firenvim',
    run = function() vim.fn['firenvim#install'](0) end
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
  --  requires = { 'kyazdani42/nvim-web-devicons' },
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
  },
  {
    "kylechui/nvim-surround",
    tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = get_config('_surround').setup
  },
  {
    'stevearc/aerial.nvim',
    config = get_config('_aerial').setup
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
    requires = { 'obaland/vfiler-column-devicons', 'kyazdani42/nvim-web-devicons' },
    config = get_config('_vfiler').setup,
  },
  {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = get_config('_fzflua').setup,
    disable = api.env.is_win_os(),
  },
  {
    'amirrezaask/fuzzy.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = get_config('_fuzzy').setup,
    disable = true,
  },
  -- ################################################
  -- # Trouble
  -- ################################################
  {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = get_config('_trouble').setup,
  },
  {
    "nvim-neotest/neotest",
    requires = {
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
  },
  -- ################################################
  -- # UI
  -- ################################################
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
  },
  {
    'akinsho/bufferline.nvim',
    tag = "v2.*",
    requires = {
      'kyazdani42/nvim-web-devicons'
    },
    config = get_config('_buffer_line').setup,
  },
  {
    'b0o/incline.nvim',
    config = get_config('_incline').setup,
  },
  {
    'sindrets/diffview.nvim',
    requires = 'nvim-lua/plenary.nvim',
  },
  {
    'nvim-telescope/telescope.nvim',
    requires = { 'folke/trouble.nvim', 'nvim-lua/plenary.nvim', 'akinsho/flutter-tools.nvim' },
    config = get_config('_telescope').setup,
  },
  {
    'folke/which-key.nvim',
    config = get_config('_whichkey').setup,
  },
  { "voldikss/vim-floaterm" },
  {
    'akinsho/toggleterm.nvim',
    tag = '*',
    config = get_config('_toggleterm').setup,
  },
  {
    'kevinhwang91/nvim-ufo',
    requires = {
      'kevinhwang91/promise-async',
      'nvim-treesitter/nvim-treesitter'
    },
    config = get_config('_ufo').setup,
  },
  --{
  --  'edluffy/specs.nvim',
  --  config = get_config('_specs').setup,
  --},
  {
    'folke/noice.nvim',
    config = get_config('_noice').setup,
    requires = {
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
    requires = { 'nvim-lua/plenary.nvim' },
    config = get_config('_flutter').setup,
  },
  { "mfussenegger/nvim-dap" },
  -- ################################################
  -- # Dart
  -- ################################################
  { "dart-lang/dart-vim-plugin" },
  { "natebosch/vim-lsc" },
  { "natebosch/vim-lsc-dart" },
  { "jiangmiao/auto-pairs" },
  { 'lervag/vimtex', opt = true }, -- Use braces when passing options
  -- ################################################
  -- # Lua
  -- ################################################
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
  },
  {
    'TimUntersberger/neogit',
    requires = 'nvim-lua/plenary.nvim',
  },
  {
    'pwntester/octo.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'kyazdani42/nvim-web-devicons',
    },
    config = get_config('_octo').setup,
  },
  { 'kdheepak/lazygit.nvim' },
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
    requires = { "vim-denops/denops.vim" },
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
    requires = "L3MON4D3/LuaSnip",
  },
  {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    requires = {
      'ray-x/lsp_signature.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'onsails/lspkind.nvim',
      'kevinhwang91/nvim-ufo',
    },
    config = get_config('_mason').setup,
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
  },
  -- ################################################
  -- # Auto Complete
  -- ################################################
  {
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'JoosepAlviste/nvim-ts-context-commentstring',
      'windwp/nvim-ts-autotag',
      'nvim-treesitter/nvim-treesitter-refactor',
      'nvim-treesitter/nvim-treesitter-context',
      'windwp/nvim-ts-autotag',
      'p00f/nvim-ts-rainbow',
    },
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
    config = get_config('_treesitter').setup,
  },
  {
    'KadoBOT/cmp-plugins',
    config = get_config('_cmp_plugins').setup,
  },
  {
    "hrsh7th/nvim-cmp",
    requires = {
      'chrisgrieser/cmp-nerdfont',
      'f3fora/cmp-spell',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-calc',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-emoji',
      'jc-doyle/cmp-pandoc-references',
      'KadoBOT/cmp-plugins',
      'octaltree/cmp-look',
      'ray-x/cmp-treesitter',
    },
    config = get_config('_cmp').setup,
  },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-vsnip" },
  { "hrsh7th/vim-vsnip" },
  { "hrsh7th/vim-vsnip-integ" },
  {
    'jose-elias-alvarez/null-ls.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = get_config('_null_ls').setup,
  },
  {
    'alec-gibson/nvim-tetris'
  },
}

return M
