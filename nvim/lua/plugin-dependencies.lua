-- check if packer is installed (~/local/share/nvim/site/pack)
local packer_exists = pcall(vim.cmd, [[packadd packer.nvim]])

if not packer_exists then
	if vim.fn.input("Hent packer.nvim? (y for yada)") ~= "y" then
		return
	end

	local directory = string.format(
	'%s/site/pack/packer/opt/',
	vim.fn.stdpath('data')
	)

	vim.fn.mkdir(directory, 'p')

	local git_clone_cmd = vim.fn.system(string.format(
	'git clone %s %s',
	'https://github.com/wbthomason/packer.nvim',
	directory .. '/packer.nvim'
	))

	print(git_clone_cmd)
	print("Henter packer.nvim...")

	return
end

return require('packer').startup(function()
  -- self manage
  use {
    'wbthomason/packer.nvim',
    opt = true
  }
  -- patch
  use 'antoinemadec/FixCursorHold.nvim'
  -- ################################################
  -- # Color
  -- ################################################
  use {
    'folke/tokyonight.nvim',
    config = function()
      require('config._tokyonight')
   end,
  }
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
    'williamboman/nvim-lsp-installer',
    requires = {'neovim/nvim-lspconfig'},
  }
  -- ################################################
  -- # Flutter
  -- ################################################
  use {
    'akinsho/flutter-tools.nvim',
    requires = {'nvim-lua/plenary.nvim'},
    config = function()
      require('config._flutter-tools')
      vim.api.nvim_set_keymap('n', '<Leader>fr',':FlutterRun -d web-server<CR>'
      , { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<Leader>fc',
      [[<Cmd>lua require('telescope').extensions.flutter.commands()<CR>]],
      { noremap = true, silent = true })
    end,
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
      'neovim/nvim-lspconfig',
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
    config = function()
      require('config._cmp')
    end,
  } 
use 'neovim/nvim-lspconfig'
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

