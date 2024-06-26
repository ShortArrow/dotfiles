local M = {}

M.setup = function()
  local _vfiler_action = require('vfiler/action')
  local _vfiler_config = require('vfiler/config')
  _vfiler_config.setup {
    options = {
      name = 'vfiler',
      auto_cd = true,
      auto_resize = true,
      keep = false,
      layout = 'floating',
      columns = 'indent,devicons,name,git',
      preview = {
        layout = 'right',
      },
    },
    mappings = {
      ['<S-Space><S-Space>'] = function(vfiler, context, view)
        _vfiler_action.toggle_select(vfiler, context, view)
        _vfiler_action.move_cursor_up(vfiler, context, view)
      end,
      ['<Space><Space>'] = function(vfiler, context, view)
        _vfiler_action.toggle_select(vfiler, context, view)
        _vfiler_action.move_cursor_down(vfiler, context, view)
      end,
    },
  }
  _vfiler_config.unmap('<Space>')
  _vfiler_config.unmap('<S-Space>')
  _vfiler_action.setup {
    hook = {},
  }
  require('vfiler/columns/indent').setup {
    icon = ''
  }
end

return M
