local M = {}

M.setup = function()
  local telescope = require('telescope')
  local actions = require("telescope.actions")
  -- local actions_set = require('telescope.actions.set')
  -- local themes = require('telescope.themes')
  -- local trouble = require('trouble.providers.telescope')
  telescope.setup {
    defaults = {
      layout = 'vertical',
      layout_strategy = 'vertical',
      winblend = 10,
      prompt_prefix = ' ',
      selection_caret = ' ',
      entry_prefix = '  ',
      initial_mode = 'insert',
      border = true,
      sorting_strategy = 'ascending',
      path_display = { 'truncate' },
      file_ignore_patterns = {
        'node_modules'
      },
      -- mappings = {
      --   i = {
      --     ['<esc>'] = actions.close,
      --     ['<C-h>'] = 'which_key',
      --     ['<C-Down>'] = actions.cycle_history_next,
      --     ['<C-Up>'] = actions.cycle_history_prev,
      --     ['<C-j>'] = actions.cycle_history_next,
      --     ['<C-k>'] = actions.cycle_history_prev,
      --     -- ['<C-t>'] = trouble.open_with_trouble,
      --   },
      --   n = {
      --     --  ["<C-t>"] = trouble.open_with_trouble,
      --   },
      -- },
      layout_config = {
        vertical = {
          width = 0.7,
        },
        horizontal = {
          height = 0.8,
          preview_cutoff = 120,
          preview_width = 200,
          prompt_position = 'top',
          width = 0.8,
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
end

return M
