-- vfiler
local vfiler = {}
vfiler.config = function()
  require('vfiler/config').setup {
    options = {
      auto_cd = true,
      auto_resize = true,
      keep = true,
      layout = 'left',
      name = 'explorer',
      width = 30,
      columns = 'indent,devicons,name',
    },
  }
  -- Start by partially changing the configurations from the default.
  local action = require'vfiler/action'
  local configs = {
    options = {
      name = 'myfiler',
      preview = {
        layout = 'right',
      },
    },
  
    mappings = {
      ['<C-l>'] = action.open_tree,
      ['<C-h>'] = action.close_tree_or_cd,
    },
  }
  
  -- Start vfiler.vim
  require'vfiler'.start(dirpath, configs)
  -- require('vfiler').start()

end
return vfiler

