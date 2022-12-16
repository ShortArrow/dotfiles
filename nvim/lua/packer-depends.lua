local api = require('my.api')
local install_path = ("%s/site/pack/packer-lib/opt/packer.nvim"):format(vim.fn.stdpath "data")

local function install_packer()
  vim.fn.termopen(("git clone https://github.com/wbthomason/packer.nvim %q"):format(install_path))
end

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  install_packer()
end

vim.cmd [[packadd packer.nvim]]

function _G.packer_upgrade()
  vim.fn.delete(install_path, "rf")
  install_packer()
end

vim.cmd [[command! PackerUpgrade :call v:lua.packer_upgrade()]]

local _packer = require('packer')

local function get_config(name)
  return require(string.format('config.%s', name))
end

local function spec(use)
  -- self manage
  use 'wbthomason/packer.nvim'
  use 'lewis6991/impatient.nvim'
  use 'nvim-lua/plenary.nvim'
  -- ################################################
  -- # Color
  -- ################################################
  use {
    'folke/tokyonight.nvim',
    config = get_config('_tokyonight').setup,
  }
  use { 'RRethy/vim-illuminate' }
  use {
    "folke/twilight.nvim",
    config = get_config('_twilight').setup,
  }
  -- ################################################
  -- # Fonts
  -- ################################################
  -- use {
  --  'yamatsum/nvim-nonicons',
  --  requires = { 'kyazdani42/nvim-web-devicons' }
  --}
  use {
    'uga-rosa/jam.nvim'
  }
  -- ################################################
  -- # Motion
  -- ################################################
  use {
    'phaazon/hop.nvim',
    config = get_config('_hop').setup,
  }
  use {
    "kylechui/nvim-surround",
    tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = get_config('_surround').setup
  }
  use {
    'stevearc/aerial.nvim',
    config = get_config('_aerial').setup
  }
  -- ################################################
  -- # Explorer
  -- ################################################
  use {
    'obaland/vfiler.vim',
    requires = { 'obaland/vfiler-column-devicons', 'kyazdani42/nvim-web-devicons' },
    config = get_config('_vfiler').setup,
  }
  use {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = get_config('_fzflua').setup,
    disable = api.env.is_win_os(),
  }
  use {
    'amirrezaask/fuzzy.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = get_config('_fuzzy').setup,
    disable = true,
  }
  -- ################################################
  -- # Trouble
  -- ################################################
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = get_config('_trouble').setup,
  }
  use {
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
  }
  -- ################################################
  -- # UI
  -- ################################################
  use {
    'simrat39/symbols-outline.nvim',
    config = get_config('_symbols_outline').setup,
  }
  use {
    'feline-nvim/feline.nvim',
    require = { 'nvim-lua/plenary.nvim', 'lewis6991/gitsigns.nvim' },
    config = get_config('_feline').setup,
  }
  use {
    'akinsho/bufferline.nvim',
    tag = "v2.*",
    requires = {
      'kyazdani42/nvim-web-devicons'
    },
    config = get_config('_buffer_line').setup,
  }
  use {
    'b0o/incline.nvim',
    config = get_config('_incline').setup,
  }
  use {
    'sindrets/diffview.nvim',
    requires = 'nvim-lua/plenary.nvim',
  }
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'folke/trouble.nvim', 'nvim-lua/plenary.nvim', 'akinsho/flutter-tools.nvim' },
    config = get_config('_telescope').setup,
  }
  use {
    'folke/which-key.nvim',
    config = get_config('_whichkey').setup,
  }
  use 'voldikss/vim-floaterm'
  use {
    'akinsho/toggleterm.nvim',
    tag = '*',
    config = get_config('_toggleterm').setup,
  }
  use {
    'kevinhwang91/nvim-ufo',
    requires = {
      'kevinhwang91/promise-async',
      'nvim-treesitter/nvim-treesitter'
    },
    config = get_config('_ufo').setup,
  }
  --use {
  --  'edluffy/specs.nvim',
  --  config = get_config('_specs').setup,
  --}
  use {
    'folke/noice.nvim',
    config = get_config('_noice').setup,
    requires = {
      -- if you lazy-load any plugin below, make sure to add proper `module='...'` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    }
  }
  --use {
  --  'yamatsum/nvim-cursorline',
  --  config = get_config('_cursorline').setup,
  --}
  -- ################################################
  -- # Flutter
  -- ################################################
  use {
    'akinsho/flutter-tools.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = get_config('_flutter').setup,
  }
  use 'mfussenegger/nvim-dap'
  -- ################################################
  -- # Dart
  -- ################################################
  use 'dart-lang/dart-vim-plugin'
  use 'natebosch/vim-lsc'
  use 'natebosch/vim-lsc-dart'
  use 'jiangmiao/auto-pairs'
  use { 'lervag/vimtex', opt = true } -- Use braces when passing options
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
    config = get_config('_gitsigns').setup,
  }
  use {
    'tpope/vim-fugitive',
    config = get_config('_fugitive').setup,
  }
  use {
    'TimUntersberger/neogit',
    requires = 'nvim-lua/plenary.nvim',
  }
  use {
    'pwntester/octo.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'kyazdani42/nvim-web-devicons',
    },
    config = get_config('_octo').setup,
  }
  -- ################################################
  -- # Indent and Bracket
  -- ################################################
  use {
    "lukas-reineke/indent-blankline.nvim",
    config = get_config('_indent').setup,
  }
  -- ################################################
  -- # Comment
  -- ################################################
  use {
    'numToStr/Comment.nvim',
    config = get_config('_comment').setup,
  }
  -- use {
  --   'JoosepAlviste/nvim-ts-context-commentstring',
  --   requires = { 'nvim-treesitter/nvim-treesitter' },
  -- }
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
      'kevinhwang91/nvim-ufo',
    },
    config = get_config('_mason').setup,
  }
  use {
    "ray-x/lsp_signature.nvim",
    config = get_config('_lsp_sig').setup,
  }
  use {
    'onsails/lspkind.nvim',
    config = get_config('_lsp_kind').setup,
  }
  use {
    'weilbith/nvim-code-action-menu',
    cmd = 'CodeActionMenu',
  }
  use {
    "glepnir/lspsaga.nvim",
    branch = "main",
    config = get_config('_lsp_saga').setup,
  }
  -- ################################################
  -- # Auto Complete
  -- ################################################
  use {
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'nvim-treesitter/nvim-treesitter-refactor',
      'windwp/nvim-ts-autotag',
      'p00f/nvim-ts-rainbow',
    },
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
    config = get_config('_treesitter').setup,
  }
  use {
    'KadoBOT/cmp-plugins',
    config = get_config('_cmp_plugins').setup,
  }
  use {
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
      'hrsh7th/cmp-emoji',
      'jc-doyle/cmp-pandoc-references',
      'KadoBOT/cmp-plugins',
      'octaltree/cmp-look',
      'ray-x/cmp-treesitter',
      'tzachar/cmp-tabnine',
    },
    config = get_config('_cmp').setup,
  }
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use {
    'hrsh7th/cmp-cmdline',
    config = get_config('_cmp_cli').setup,
  }
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'
  use 'hrsh7th/vim-vsnip-integ'
  use {
    'jose-elias-alvarez/null-ls.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = get_config('_null_ls').setup,
  }
  use {
    'alec-gibson/nvim-tetris'
  }
end

_packer.startup {
  spec,
  config = {
    display = {
      open_fn = require("packer.util").float,
    },
    max_jobs = vim.fn.has "win32" == 1 and 5 or nil,
  },
}
