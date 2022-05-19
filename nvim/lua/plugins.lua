vim.cmd[[packadd packer.nvim]]

return require('packer').startup(function()
  -- self manage
  use 'wbthomason/packer.nvim'
  -- load on start up
  use 'lambdalisue/fern.vim'
  use 'feline-nvim/feline.nvim'
  -- use 'mortepau/codicons.nvim'
  use {
   'yamatsum/nvim-nonicons',
   requires = {'kyazdani42/nvim-web-devicons'}
  }
  use 'lambdalisue/nerdfont.vim'
  use 'lambdalisue/fern-renderer-nerdfont.vim'
  -- use {
  --  'nvim-lualine/lualine.nvim',
  --  requires = { 'yamatsum/nvim-nonicons', opt = true }
  -- }
  use 'lambdalisue/fern-git-status.vim'
  use 'ryanoasis/vim-devicons'
  -- ################################################
  -- # need nvim 0.7 after here
  -- ################################################
  -- use {
  --   'nvim-telescope/telescope.nvim',
  --   requires = { {'nvim-lua/plenary.nvim'} }
  --- }
end)

