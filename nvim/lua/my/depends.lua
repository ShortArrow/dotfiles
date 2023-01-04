local api = require('my')
local keymaps = require('my.keymaps')

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
  whichkey   = { name = 'whichkey', keymaps = keymaps.WhichKey },
  ufo   = { name = 'ufo', keymaps = keymaps.Ufo },
  diffview   = { name = 'diffview', keymaps = keymaps.DiffView },
  hop   = { name = 'hop', keymaps = keymaps.Hop },
  neogit   = { name = 'neogit', keymaps = keymaps.Neogit },
  lazygit   = { name = 'lazygit', keymaps = keymaps.LazyGit },
}

return M
