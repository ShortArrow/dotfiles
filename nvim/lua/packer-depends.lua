vim.cmd[[packadd packer.nvim]]

local _packer = require('packer')
local use = _packer.use

local function get_config(name)
	return require(string.format('config/%s', name))
end

return _packer.startup(function()
  -- self manage
  use {
    'wbthomason/packer.nvim',
    opt = true
  }
  -- ################################################
  -- # Color
  -- ################################################
  use {
    'folke/tokyonight.nvim',
    config = get_config('_tokyonight').setup
  }
  -- ################################################
  -- # Fonts
  -- ################################################
  use {
    'yamatsum/nvim-nonicons',
    requires = {'kyazdani42/nvim-web-devicons'}
  }
  -- ################################################
  -- # Explorer
  -- ################################################
  use {
    'obaland/vfiler.vim',
    requires = {'obaland/vfiler-column-devicons', 'kyazdani42/nvim-web-devicons', 'ryanoasis/vim-devicons'},
    config = get_config('_vfiler').setup
  }
  use {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    requires = { 'kyazdani42/nvim-web-devicons' }
  }
  -- ################################################
  -- # Status line
  -- ################################################
  use {
    'feline-nvim/feline.nvim',
    config = get_config('_feline').setup
  }
  use 'b0o/incline.nvim'
  -- ################################################
  -- # Trouble
  -- ################################################
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = get_config('_trouble').setup
  }
  -- ################################################
  -- # UI
  -- ################################################
  use {
    'nvim-telescope/telescope.nvim',
    requires = {'folke/trouble.nvim', 'nvim-lua/plenary.nvim', 'akinsho/flutter-tools.nvim'},
    config = get_config('_telescope').setup
  }
  -- ################################################
  -- # Flutter
  -- ################################################
  use {
    'akinsho/flutter-tools.nvim',
    requires = {'nvim-lua/plenary.nvim'},
    config = get_config('_flutter').setup
  }
  use 'mfussenegger/nvim-dap'
  -- ################################################
  -- # Dart
  -- ################################################
  use 'dart-lang/dart-vim-plugin'
  use 'natebosch/vim-lsc'
  use 'natebosch/vim-lsc-dart'
  use 'jiangmiao/auto-pairs'
  use  {'lervag/vimtex', opt = true}      -- Use braces when passing options
  -- ################################################
  -- # Lua
  -- ################################################
  -- Install this plugin.
  use 'tjdevries/nlua.nvim'
  -- (OPTIONAL): This is recommended to get better auto-completion UX experience for builtin LSP.
  -- use 'nvim-lua/completion-nvim'
  -- (OPTIONAL): This is a suggested plugin to get better Lua syntax highlighting
  --   but it's not currently required
  use 'euclidianAce/BetterLua.vim'
  -- (OPTIONAL): If you wish to have fancy lua folds, you can check this out.
  use 'tjdevries/manillua.nvim'
  -- ################################################
  -- # Git
  -- ################################################
  use {
    'lewis6991/gitsigns.nvim',
    config = get_config('_gitsigns').setup
  }
  use {
    'tpope/vim-fugitive',
    config = get_config('_fugitive').setup
  }
  -- ################################################
  -- # LSP
  -- ################################################
  use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    requires = {
      'ray-x/lsp_signature.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'onsails/lspkind.nvim',
    },
    config = get_config('_mason').setup
  }
  use {
    "ray-x/lsp_signature.nvim",
    config = get_config('_lsp_sig').setup
  }
  use {
    'onsails/lspkind.nvim',
    config = get_config('_lsp_kind').setup
  }
  use {
    'weilbith/nvim-code-action-menu',
    cmd = 'CodeActionMenu',
  }
  -- ################################################
  -- # Auto Complete
  -- ################################################
  use {
    "hrsh7th/nvim-cmp",
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'octaltree/cmp-look',
      'hrsh7th/cmp-calc',
      'f3fora/cmp-spell',
      'hrsh7th/cmp-emoji',
      'quangnguyen30192/cmp-nvim-ultisnips',
    },
    config = get_config('_cmp').setup
  }
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  -- For vsnip users.
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'
  -- For luasnip users.
  -- use 'L3MON4D3/LuaSnip'
  -- use 'saadparwaiz1/cmp_luasnip'
  -- For ultisnips users.
  -- use 'SirVer/ultisnips'
  -- use 'quangnguyen30192/cmp-nvim-ultisnips'
  -- For snippy users.
  -- use 'dcampos/nvim-snippy'
  -- use 'dcampos/cmp-snippy'


  -- use {
  --    'tzachar/cmp-tabnine',
  --    run = '$HOME/.local/share/nvim/site/pack/packer/start/cmp-tabnine/install.sh',
  --    requires = 'hrsh7th/nvim-cmp'
  -- }
  use 'hrsh7th/vim-vsnip-integ'
end)

