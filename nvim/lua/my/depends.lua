local api = require('my/api')
local keymaps = require('my/keymaps')

local M = {
  common     = { name = 'common', keymaps = keymaps.Common },
  fugitive   = { name = 'fugitive', keymaps = keymaps.Fugitive },
  flutter    = { name = 'flutter', keymaps = keymaps.Flutter },
  trouble    = { name = 'trouble', keymaps = keymaps.Trouble },
  fzflua     = { name = 'fzflua', keymaps = keymaps.FzfLua,
    disable = api.env.is_win_os() },
  packer     = { name = 'packer', keymaps = keymaps.Packer },
  vfiler     = { name = 'vfiler', keymaps = keymaps.VFiler },
  floaterm   = { name = 'floaterm', keymaps = keymaps.Floaterm },
  toggleterm = { name = 'toggleterm', keymaps = keymaps.ToggleTerm },
  lspsaga    = { name = 'lspsaga', keymaps = keymaps.LspSaga },
  python     = { name = 'python', env = api.lang.python.env },
}

return M
