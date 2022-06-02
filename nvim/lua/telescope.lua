-- telescope
local telescope = {}
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

