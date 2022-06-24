local M = {}

function M.setup()
  local _vfiler = require('vfiler')
  local _vfiler_action = require('vfiler/action')
  local _vfiler_config = require('vfiler/config')
  _vfiler_config.setup {
    options = {
      name = 'myfiler',
      auto_cd = true,
      auto_resize = true,
      keep = true,
      layout = 'left',
      width = 30,
      columns = 'indent,devicons,name,git',
      preview = {
        layout = 'right',
      },
    },
    mappings = {},
  }
  _vfiler_action.setup {
    hook = {},
  }
  _vfiler.start()
end

return M
