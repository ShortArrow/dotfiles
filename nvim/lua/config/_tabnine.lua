local M = {}

M.setup = function()
  local config = require('cmp_tabnine.config')
  config:setup {
    max_lines = 1000,
    max_num_results = 20,
    sort = true,
    run_on_every_keystroke = true,
    snippet_placeholder = '..',
    ignored_file_types = {
      -- default is not to ignore
      -- uncomment to ignore in lua:
      -- lua = true
    },
    show_prediction_strength = false,
  }

  local tabnine = require('cmp_tabnine')
  local prefetch = vim.api.nvim_create_augroup("prefetch", { clear = true })
  vim.api.nvim_create_autocmd('BufRead', {
    group = prefetch,
    pattern = '*.py',
    callback = function()
      tabnine:prefetch(vim.fn.expand('%:p'))
    end
  })
end

return M
