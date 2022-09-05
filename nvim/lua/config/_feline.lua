local M = {}
M.lsp = require 'feline.providers.lsp'
M.vi_mode_utils = require 'feline.providers.vi_mode'

M.colors = {
  bg = '#282c34',
  fg = '#abb2bf',
  yellow = '#e0af68',
  cyan = '#56b6c2',
  darkblue = '#081633',
  green = '#98c379',
  orange = '#d19a66',
  violet = '#a9a1e1',
  magenta = '#c678dd',
  blue = '#61afef',
  red = '#e86671'
}

M.vi_mode_colors = {
  NORMAL = M.colors.green,
  INSERT = M.colors.red,
  VISUAL = M.colors.magenta,
  OP = M.colors.green,
  BLOCK = M.colors.blue,
  REPLACE = M.colors.violet,
  ['V-REPLACE'] = M.colors.violet,
  ENTER = M.colors.cyan,
  MORE = M.colors.cyan,
  SELECT = M.colors.orange,
  COMMAND = M.colors.green,
  SHELL = M.colors.green,
  TERM = M.colors.green,
  NONE = M.colors.yellow
}

M.icons = {
  linux = ' ',
  macos = ' ',
  windows = ' ',

  errs = ' ',
  warns = ' ',
  infos = ' ',
  hints = ' ',

  lsp = ' ',
  git = ''
}

M.file_osinfo = function()
  local os = vim.bo.fileformat:upper()
  local icon
  if os == 'UNIX' then
    icon = M.icons.linux
  elseif os == 'MAC' then
    icon = M.icons.macos
  else
    icon = M.icons.windows
  end
  return icon .. os
end

M.lsp_diagnostics_info = function()
  return {
    errs = M.lsp.get_diagnostics_count('Error'),
    warns = M.lsp.get_diagnostics_count('Warning'),
    infos = M.lsp.get_diagnostics_count('Information'),
    hints = M.lsp.get_diagnostics_count('Hint')
  }
end

M.diag_enable = function(f, s)
  return function()
    local diag = f()[s]
    return diag and diag ~= 0
  end
end

M.diag_of = function(f, s)
  local icon = M.icons[s]
  return function()
    local diag = f()[s]
    return icon .. diag
  end
end

M.vimode_hl = function()
  return {
    name = M.vi_mode_utils.get_mode_highlight_name(),
    fg = M.vi_mode_utils.get_mode_color()
  }
end

-- LuaFormatter off

local comps = {
  vi_mode = {
    left = {
      provider = '▊',
      hl = M.vimode_hl,
      right_sep = ' '
    },
    right = {
      provider = '▊',
      hl = M.vimode_hl,
      left_sep = ' '
    }
  },
  file = {
    info = {
      provider = 'file_info',
      hl = {
        fg = M.colors.blue,
        style = 'bold'
      }
    },
    encoding = {
      provider = 'file_encoding',
      left_sep = ' ',
      hl = {
        fg = M.colors.violet,
        style = 'bold'
      }
    },
    type = {
      provider = 'file_type'
    },
    os = {
      provider = M.file_osinfo,
      left_sep = ' ',
      hl = {
        fg = M.colors.violet,
        style = 'bold'
      }
    }
  },
  line_percentage = {
    provider = 'line_percentage',
    left_sep = ' ',
    hl = {
      style = 'bold'
    }
  },
  scroll_bar = {
    provider = 'scroll_bar',
    left_sep = ' ',
    hl = {
      fg = M.colors.blue,
      style = 'bold'
    }
  },
  diagnos = {
    err = {
      provider = M.diag_of(M.lsp_diagnostics_info, 'errs'),
      left_sep = ' ',
      enabled = M.diag_enable(M.lsp_diagnostics_info, 'errs'),
      hl = {
        fg = M.colors.red
      }
    },
    warn = {
      provider = M.diag_of(M.lsp_diagnostics_info, 'warns'),
      left_sep = ' ',
      enabled = M.diag_enable(M.lsp_diagnostics_info, 'warns'),
      hl = {
        fg = M.colors.yellow
      }
    },
    info = {
      provider = M.diag_of(M.lsp_diagnostics_info, 'infos'),
      left_sep = ' ',
      enabled = M.diag_enable(M.lsp_diagnostics_info, 'infos'),
      hl = {
        fg = M.colors.blue
      }
    },
    hint = {
      provider = M.diag_of(M.lsp_diagnostics_info, 'hints'),
      left_sep = ' ',
      enabled = M.diag_enable(M.lsp_diagnostics_info, 'hints'),
      hl = {
        fg = M.colors.cyan
      }
    },
  },
  lsp = {
    name = {
      provider = 'lsp_client_names',
      left_sep = ' ',
      icon = M.icons.lsp,
      hl = {
        fg = M.colors.yellow
      }
    }
  },
  git = {
    branch = {
      provider = 'git_branch',
      icon = M.icons.git,
      left_sep = ' ',
      hl = {
        fg = M.colors.violet,
        style = 'bold'
      },
    },
    add = {
      provider = 'git_diff_added',
      hl = {
        fg = M.colors.green
      }
    },
    change = {
      provider = 'git_diff_changed',
      hl = {
        fg = M.colors.orange
      }
    },
    remove = {
      provider = 'git_diff_removed',
      hl = {
        fg = M.colors.red
      }
    }
  }
}

M.properties = {
  force_inactive = {
    filetypes = {
      'NvimTree',
      'dbui',
      'packer',
      'startify',
      'fugitive',
      'fugitiveblame'
    },
    buftypes = { 'terminal' },
    bufnames = {}
  }
}

M.components = {
  left = {
    active = {
      comps.vi_mode.left,
      comps.file.info,
      comps.lsp.name,
      comps.diagnos.err,
      comps.diagnos.warn,
      comps.diagnos.hint,
      comps.diagnos.info
    },
    inactive = {
      comps.vi_mode.left,
      comps.file.info
    }
  },
  mid = {
    active = {},
    inactive = {}
  },
  right = {
    active = {
      comps.git.add,
      comps.git.change,
      comps.git.remove,
      comps.file.os,
      comps.git.branch,
      comps.line_percentage,
      comps.scroll_bar,
      comps.vi_mode.right
    },
    inactive = {}
  }
}

M.setup = function()
  require('feline').setup({
    --default_bg = M.colors.bg,
    --default_fg = colors.fg,
    --components = components,
    --properties = M.properties,
    --vi_mode_colors = M.vi_mode_colors
  })
end

return M
