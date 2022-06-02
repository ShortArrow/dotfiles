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
    config = function()
      require('vfiler/config').setup {
        options = {
          auto_cd = true,
          auto_resize = true,
          keep = true,
          layout = 'left',
          name = 'explorer',
          width = 30,
          columns = 'indent,icon,name',
        },
      }
      -- Start by partially changing the configurations from the default.
      local action = require'vfiler/action'
      local configs = {
        options = {
          name = 'myfiler',
          preview = {
            layout = 'right',
          },
        },
      
        mappings = {
          ['<C-l>'] = action.open_tree,
          ['<C-h>'] = action.close_tree_or_cd,
        },
      }
      
      -- Start vfiler.vim
      require'vfiler'.start(dirpath, configs)
      -- require('vfiler').start()
    end,
  }
  use {
    'lambdalisue/fern.vim',
    config = function()
      vim.g['fern#default_hidden'] = '1'
    end,
  }
  use {
    'lambdalisue/fern-renderer-nerdfont.vim',
    requires = {
      'lambdalisue/fern.vim',
      'lambdalisue/nerdfont.vim'
    },
    config = function()
      vim.g['fern#renderer'] = 'nerdfont'
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
      vim.g['fern#comparator '] = 'lexical'
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
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      local actions_set = require('telescope.actions.set')
      local themes = require('telescope.themes')
      
      telescope.setup{
        defaults = {
          layout = 'horizontal',
          winblend = 20,
          prompt_prefix = 'ﱢ ',
          selection_caret = ' ',
          entry_prefix = '  ',
          initial_mode = 'insert',
          border = false,
          sorting_strategy = 'ascending',
          path_display = { 'truncate' },
          mappings = {
            i = {
              ['<esc>'] = actions.close,
              ['<C-h>'] = 'which_key',
              ['<C-Down>'] = actions.cycle_history_next,
              ['<C-Up>'] = actions.cycle_history_prev,
              ['<C-j>'] = actions.cycle_history_next,
              ['<C-k>'] = actions.cycle_history_prev,
            },
            n = {  },
          },
          layout_config = {
            horizontal = {
              height = 0.7,
              preview_cutoff = 120,
              preview_width = 50,
              prompt_position = 'top',
              width = 0.7,
            },
            cursor = {
              height = 0.2,
              preview_cutoff = 40,
              width = 0.6
            }
          }
        },
        pickers = {
          registers = {
            theme = 'cursor'
          },
          lsp_code_actions = {
            theme = 'cursor'
          }
        },
        extensions = {}
      }
      telescope.load_extension "flutter"
    end,
  }
  -- ################################################
  -- # Flutter
  -- ################################################
  use 'neovim/nvim-lspconfig' -- Collection of configurations for the built-in LSP client
  use {'akinsho/flutter-tools.nvim', requires = 'nvim-lua/plenary.nvim',
    config = function()
      require("flutter-tools").setup{
        lsp = {
          color = {
            enabled = true,
            background = true, 
            foreground = true,
            virtual_text = true,
            virtual_text_str = "■",
          },
          on_attach = function(client, bufnr)
            vim.cmd [[hi FlutterWidgetGuides ctermfg=237 guifg=#33374c]]
            vim.cmd [[hi ClosingTags ctermfg=244 guifg=#8389a3]]
            on_attach(client, bufnr)
          end,
          capabilities = capabilities,
          widget_guides = {
            enabled = true,
          },
          debugger = {
          enabled = true,
            register_configurations = function(_)
              require("dap").configurations.dart = {}
              require("dap.ext.vscode").load_launchjs()
            end,
          },
        }
      }
    end,
  }
  -- with packer
  use 'mfussenegger/nvim-dap'
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
      require("trouble").setup{
        {
          position = "bottom", -- position of the list can be: bottom, top, left, right
          height = 10, -- height of the trouble list when position is top or bottom
          width = 50, -- width of the list when position is left or right
          icons = true, -- use devicons for filenames
          mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
          fold_open = "", -- icon used for open folds
          fold_closed = "", -- icon used for closed folds
          group = true, -- group results by file
          padding = true, -- add an extra new line on top of the list
          action_keys = { -- key mappings for actions in the trouble list
              -- map to {} to remove a mapping, for example:
              -- close = {},
              close = "q", -- close the list
              cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
              refresh = "r", -- manually refresh
              jump = {"<cr>", "<tab>"}, -- jump to the diagnostic or open / close folds
              open_split = { "<c-x>" }, -- open buffer in new split
              open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
              open_tab = { "<c-t>" }, -- open buffer in new tab
              jump_close = {"o"}, -- jump to the diagnostic and close the list
              toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
              toggle_preview = "P", -- toggle auto_preview
              hover = "K", -- opens a small popup with the full multiline message
              preview = "p", -- preview the diagnostic location
              close_folds = {"zM", "zm"}, -- close all folds
              open_folds = {"zR", "zr"}, -- open all folds
              toggle_fold = {"zA", "za"}, -- toggle fold of current file
              previous = "k", -- preview item
              next = "j" -- next item
          },
          indent_lines = true, -- add an indent guide below the fold icons
          auto_open = false, -- automatically open the list when you have diagnostics
          auto_close = false, -- automatically close the list when you have no diagnostics
          auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
          auto_fold = false, -- automatically fold a file trouble list at creation
          auto_jump = {"lsp_definitions"}, -- for the given modes, automatically jump if there is only a single result
          signs = {
              -- icons / text used for a diagnostic
              error = "",
              warning = "",
              hint = "",
              information = "",
              other = "﫠"
          },
          use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
        }
      }
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
    }
    use {
        'tzachar/cmp-tabnine',
        run = './install.sh',
        requires = 'hrsh7th/nvim-cmp'
    }
end)

