vim.cmd[[packadd packer.nvim]]

return require('packer').startup(function()
  -- self manage
  use 'wbthomason/packer.nvim'
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
  use 'lambdalisue/fern.vim'
  use 'lambdalisue/fern-renderer-nerdfont.vim'
  use 'lambdalisue/fern-git-status.vim'
  use 'lambdalisue/fern-comparator-lexical.vim'
  -- ################################################
  -- # Status line
  -- ################################################
  use 'feline-nvim/feline.nvim'
  use 'b0o/incline.nvim'
  -- ################################################
  -- # UI
  -- ################################################
  use {
    'nvim-telescope/telescope.nvim',
    requires = {'nvim-lua/plenary.nvim'}
  }
  -- ################################################
  -- # Flutter
  -- ################################################
  use 'neovim/nvim-lspconfig' -- Collection of configurations for the built-in LSP client
  use {'akinsho/flutter-tools.nvim', requires = 'nvim-lua/plenary.nvim'}
  -- with packer
  use 'mfussenegger/nvim-dap'
  -- ################################################
  -- # Git
  -- ################################################
  use {
  'lewis6991/gitsigns.nvim',
  }
end)

