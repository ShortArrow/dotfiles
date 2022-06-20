vim.cmd[[packadd packer.nvim]]

return require('packer').startup(function()
  -- self manage
  use {
    'wbthomason/packer.nvim',
    opt = true
  }
  -- patch
  use 'antoinemadec/FixCursorHold.nvim'

  -- ################################################
  -- # Fonts
  -- ################################################
  use {
   'yamatsum/nvim-nonicons',
   requires = {'kyazdani42/nvim-web-devicons'}
  }
  use 'lambdalisue/nerdfont.vim'
  -- use 'mortepau/codicons.nvim'
  use 'ryanoasis/vim-devicons'

  -- ################################################
  -- # Explorer
  -- ################################################
  use {
    'obaland/vfiler.vim',
    requires = {'obaland/vfiler-column-devicons', 'kyazdani42/nvim-web-devicons', 'ryanoasis/vim-devicons'},
    config = function()
      require('config._vfiler')
    end,
  }
  use {
    'lambdalisue/fern.vim',
    config = function()
      require('config._fern')
    end,
  }
  use {
    'lambdalisue/fern-renderer-nerdfont.vim',
    requires = {
      'lambdalisue/fern.vim',
      'lambdalisue/nerdfont.vim'
    },
    config = function()
      require('config._fern-renderer-nerdfont')
    end,
  }
  use {
    'lambdalisue/fern-git-status.vim',
    requires = {
      'lambdalisue/fern.vim',
    },
  }
  use {
    'lambdalisue/fern-comparator-lexical.vim',
    requires = {
      'lambdalisue/fern.vim',
    },
    config = function()
      require('config._fern-comparator-lexical')
    end,
  }
  
  -- ################################################
  -- # Status line
  -- ################################################
  use {
    'feline-nvim/feline.nvim',
    config = function()
      require('feline').setup()
    end,
  }
  use 'b0o/incline.nvim'
  
  -- ################################################
  -- # UI
  -- ################################################
  use {
    'nvim-telescope/telescope.nvim',
    requires = {'nvim-lua/plenary.nvim', 'akinsho/flutter-tools.nvim'},
    config = function()
      require('config._telescope')
    end,
  }
  -- ################################################
  -- # LSP
  -- ################################################
  use {
    "williamboman/nvim-lsp-installer",
    "neovim/nvim-lspconfig",
  }
  -- ################################################
  -- # Flutter
  -- ################################################
  use 'neovim/nvim-lspconfig' -- Collection of configurations for the built-in LSP client
  use {
    'akinsho/flutter-tools.nvim',
    requires = {'nvim-lua/plenary.nvim'},
    config = function()
      require('config._flutter-tools')
    end,
  }
  use 'mfussenegger/nvim-dap'
  -- ################################################
  -- # Dart
  -- ################################################
  use 'dart-lang/dart-vim-plugin'
  use 'natebosch/vim-lsc'
  use 'natebosch/vim-lsc-dart'
  -- ################################################
  -- # Git
  -- ################################################
  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end
  }
  
  -- ################################################
  -- # Trouble
  -- ################################################
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require('config._trouble')
    end,
  }
  
  -- ################################################
  -- # Auto Complete
  -- ################################################
  use {
        "hrsh7th/nvim-cmp",
        requires = {
            "hrsh7th/cmp-buffer", "hrsh7th/cmp-nvim-lsp",
            'quangnguyen30192/cmp-nvim-ultisnips', 'hrsh7th/cmp-nvim-lua',
            'octaltree/cmp-look', 'hrsh7th/cmp-path', 'hrsh7th/cmp-calc',
            'f3fora/cmp-spell', 'hrsh7th/cmp-emoji'
        }
    } --completion
    use {
        'tzachar/cmp-tabnine',
        run = '$HOME/.local/share/nvim/site/pack/packer/start/cmp-tabnine/install.sh',
        requires = 'hrsh7th/nvim-cmp'
    }
end)

