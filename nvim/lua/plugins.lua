vim.cmd[[packadd packer.nvim]]

return require('packer').startup(function()
  -- self manage
  use 'wbthomason/packer.nvim'
  -- load on start up
  use 'lambdalisue/fern.vim'
  use 'antoinemadec/FixCursorHold.nvim'
  use 'feline-nvim/feline.nvim'
  -- use 'mortepau/codicons.nvim'
  use {
   'yamatsum/nvim-nonicons',
   requires = {'kyazdani42/nvim-web-devicons'}
  }
  use 'lambdalisue/nerdfont.vim'
  use 'lambdalisue/fern-renderer-nerdfont.vim'
  use 'lambdalisue/fern-git-status.vim'
  use 'ryanoasis/vim-devicons'
  -- ################################################
  -- # need nvim 0.7 after here
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
end)

