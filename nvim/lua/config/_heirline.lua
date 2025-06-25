local M = {}

local function add_color()
  local highlights = require("heirline.highlights")
  local config = require("config._tokyonight")
  local scheme = require("tokyonight.colors").setup(config.config)
  local local_scheme = {
    fg = "#c0caf5",
    bg = "#1e222a",
    cmd_info_bg = "#1e222a",
    cmd_info_fg = "#c0caf5",
    command = "red",
    mod_check = "#c0caf5",
    ui_process_cb = "#c0caf5",
    is_blocking = "#c0caf5",
    diag_ERROR = "#ff0000",
    diag_HINT = "#c0caf5",
    diag_INFO = "#c0caf5",
    diag_WARN = "#ff8800",
    diagnostics_bg = "#1e222a",
    diagnostics_fg = "#c0caf5",
    file_info_bg = "#1e222a",
    file_info_fg = "#c0caf5",
    git_added = "#c0caf5",
    git_branch_bg = "#1e222a",
    git_branch_fg = "#c0caf5",
    git_changed = "#c0caf5",
    git_diff_bg = "#1e222a",
    git_removed = "#c0caf5",
    inactive = "#4b5263",
    insert = "blue",
    lsp_bg = "#1e222a",
    lsp_fg = "#c0caf5",
    mode_fg = "#7aa2f7",
    nav_bg = "#1e222a",
    nav_fg = "#c0caf5",
    normal = "green",
    normal_bg = "#1e222a",
    normal_fg = "#c0caf5",
    scrollbar = "#c0caf5",
    tabline_bg = "blue",
    tabline_fg = "#00caf5",
    terminal = "lime",
    visual = "purple",
    winbar_fg = "#c0caf5",
    winbar_bg = "#1e222a",
  }
  scheme.normal = local_scheme.normal
  scheme.command = local_scheme.command
  scheme.visual = local_scheme.visual
  scheme.insert = local_scheme.insert
  scheme.terminal = local_scheme.terminal
  scheme.inactive = local_scheme.inactive
  scheme.cmd_info_fg = local_scheme.cmd_info_fg
  scheme.cmd_info_bg = scheme.bg
  scheme.mode_fg = local_scheme.mode_fg
  scheme.winbar_fg = local_scheme.winbar_fg
  scheme.tab_fg = local_scheme.fg
  scheme.tab_bg = local_scheme.bg
  scheme.tab_active_fg = scheme.green
  scheme.tab_active_bg = local_scheme.bg
  scheme.tab_close_fg = scheme.red
  scheme.tab_close_bg = local_scheme.bg
  scheme.tabline_fg = local_scheme.tabline_fg
  scheme.tabline_bg = local_scheme.tabline_bg
  scheme.file_info_fg = local_scheme.file_info_fg
  scheme.file_info_bg = scheme.bg
  scheme.git_added = scheme.green
  scheme.git_branch_bg = scheme.bg
  scheme.git_branch_fg = local_scheme.git_branch_fg
  scheme.git_changed = scheme.orange
  scheme.git_diff_bg = scheme.bg
  scheme.git_removed = scheme.red
  scheme.lsp_fg = local_scheme.lsp_fg
  scheme.lsp_bg = scheme.bg
  scheme.nav_fg = local_scheme.nav_fg
  scheme.nav_bg = scheme.bg
  scheme.scrollbar = local_scheme.scrollbar
  scheme.virtual_env_bg = scheme.bg
  scheme.virtual_env_fg = scheme.green
  scheme.diag_ERROR = scheme.red
  scheme.diag_HINT = scheme.purple
  scheme.diag_INFO = scheme.blue
  scheme.diag_WARN = scheme.yellow
  scheme.diagnostics_bg = scheme.bg
  scheme.diagnostics_fg = local_scheme.diagnostics_fg
  highlights.load_colors(scheme)
end

M.opts = function()
  local lib = require "heirline-components.all"
  add_color()
  return {
    opts = {
      disable_winbar_cb = function(args) -- We do this to avoid showing it on the greeter.
        local is_disabled = not require("heirline-components.buffer").is_valid(args.buf) or
            lib.condition.buffer_matches({
              buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
              filetype = { "NvimTree", "neo%-tree", "dashboard", "Outline", "aerial" },
            }, args.buf)
        return is_disabled
      end,
    },
    tabline = { -- UI upper bar
      lib.component.tabline_conditional_padding(),
      lib.component.tabline_buffers(),
      lib.component.fill { hl = { bg = "tabline_bg" } },
      lib.component.tabline_tabpages(),
    },
    winbar = { -- UI breadcrumbs bar
      init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
      fallthrough = false,
      -- Winbar for terminal, neotree, and aerial.
      {
        condition = function() return not lib.condition.is_active() end,
        {
          lib.component.neotree(),
          lib.component.compiler_play(),
          lib.component.fill(),
          lib.component.compiler_build_type(),
          lib.component.compiler_redo(),
          lib.component.aerial(),
        },
      },
      -- Regular winbar
      {
        lib.component.neotree(),
        lib.component.compiler_play(),
        lib.component.fill(),
        lib.component.breadcrumbs(),
        lib.component.fill(),
        lib.component.compiler_redo(),
        lib.component.aerial(),
      }
    },
    statuscolumn = { -- UI left column
      init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
      lib.component.foldcolumn(),
      lib.component.numbercolumn(),
      lib.component.signcolumn(),
    } or nil,
    statusline = { -- UI statusbar
      hl = { fg = "fg", bg = "bg" },
      lib.component.mode(),
      lib.component.git_branch(),
      lib.component.file_info(),
      lib.component.git_diff(),
      lib.component.diagnostics(),
      lib.component.fill(),
      lib.component.cmd_info(),
      lib.component.fill(),
      lib.component.lsp(),
      lib.component.compiler_state(),
      lib.component.virtual_env(),
      lib.component.nav(),
      lib.component.mode { surround = { separator = "right" } },
    },
  }
end

M.config = function(_, opts)
  local heirline = require("heirline")
  local heirline_components = require "heirline-components.all"

  -- Setup
  heirline_components.init.subscribe_to_events()
  heirline.load_colors(heirline_components.hl.get_colors())
  heirline.setup(opts)
end

return M
