vim.o.number = true
vim.o.termguicolors = true
vim.o.clipboard = vim.o.clipboard..'unnamedplus'
vim.o.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
vim.o.guifont = 'RobotoJ, \'cascadia code\', \'Fira Code\', \'Source Code Pro\', PlemolJP, Consolas, \'Courier New\', monospace'
vim.o.encoding = 'UTF-8'
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
require'plugins'

-- #############################
-- # UI
-- #############################
require('feline').setup()

-- #############################
-- # Trouble
-- #############################
local trouble=require("trouble")
trouble.setup()

-- #############################
-- # Flutter
-- #############################
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
local actions = require('telescope.actions')
local actions_set = require('telescope.actions.set')
local themes = require('telescope.themes')

-- #############################
-- # Telescope
-- #############################
local telescope = require('telescope')

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
	['<C-t>'] = trouble.open_with_trouble
      },
      n = { ["<c-t>"] = trouble.open_with_trouble },
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

vim.cmd[[autocmd BufWritePost plugins.lua PackerCompile]]

