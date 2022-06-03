-- vfiler-config
local action = require'vfiler/action'
local configs = {
  options = {
    name = 'myfiler',
    auto_cd = true,
    auto_resize = true,
    keep = true,
    layout = 'left',
    width = 30,
    columns = 'indent,devicons,name,git',
    show_hidden_files = true,
    preview = {
      layout = 'right',
    },
  },
  mappings = {
    ['<C-l>'] = action.open_tree,
    ['<C-h>'] = action.close_tree_or_cd,
  },
}

require'vfiler'.start(dirpath, configs)
-- require('vfiler').start()

