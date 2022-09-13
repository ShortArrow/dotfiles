local keymaps = require('keymaps')

local is_win_os = function()
  return "Windows_NT" == vim.loop.os_uname().sysname
end

local M = {
  common   = { enable = true, name = 'common', keymaps = keymaps.Common },
  fugitive = { enable = true, name = 'fugitive', keymaps = keymaps.Fugitive },
  flutter  = { enable = true, name = 'flutter', keymaps = keymaps.Flutter },
  trouble  = { enable = true, name = 'trouble', keymaps = keymaps.Trouble },
  fzflua   = { enable = is_win_os(),
    name = 'fzflua', keymaps = keymaps.FzfLua },
  packer   = { enable = true, name = 'packer', keymaps = keymaps.Packer },
  vfiler   = { enable = true, name = 'vfiler', keymaps = keymaps.VFiler },
  floaterm = { enable = true, name = 'floaterm', keymaps = keymaps.Floaterm },
  lspsaga  = { enable = true, name = 'lspsaga', keymaps = keymaps.LspSaga },
}

return M
