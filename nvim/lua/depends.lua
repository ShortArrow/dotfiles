local keymaps = require('keymaps')

local M = {
  common   = { enable = true, name = 'common', keymaps = keymaps.Common },
  fugitive = { enable = true, name = 'fugitive', keymaps = keymaps.Fugitive },
  flutter  = { enable = true, name = 'flutter', keymaps = keymaps.Flutter },
  trouble  = { enable = true, name = 'trouble', keymaps = keymaps.Trouble },
  fzflua   = { enable = true, name = 'fzflua', keymaps = keymaps.FzfLua },
  packer   = { enable = true, name = 'packer', keymaps = keymaps.Packer },
  vfiler   = { enable = true, name = 'vfiler', keymaps = keymaps.VFiler },
  floaterm = { enable = true, name = 'floaterm', keymaps = keymaps.Floaterm },
}

return M
