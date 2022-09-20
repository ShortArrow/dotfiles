local keymaps = require('my/keymaps')
local api = require('my/api')

local M = {
  common   = { name = 'common', keymaps = keymaps.Common },
  fugitive = { name = 'fugitive', keymaps = keymaps.Fugitive },
  flutter  = { name = 'flutter', keymaps = keymaps.Flutter },
  trouble  = { name = 'trouble', keymaps = keymaps.Trouble },
  fzflua   = { disable = api.env.is_win_os(),
    name = 'fzflua', keymaps = keymaps.FzfLua },
  packer   = { name = 'packer', keymaps = keymaps.Packer },
  vfiler   = { name = 'vfiler', keymaps = keymaps.VFiler },
  floaterm = { name = 'floaterm', keymaps = keymaps.Floaterm },
  lspsaga  = { name = 'lspsaga', keymaps = keymaps.LspSaga },
}

return M
