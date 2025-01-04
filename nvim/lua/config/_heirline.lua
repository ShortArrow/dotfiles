local M = {}

local function add_color()
  local highlights = require("heirline.highlights")
  highlights.load_colors({
    bg = "#1e222a",
    fg = "#c0caf5",
    winbar_fg = "#c0caf5",
    mode_fg = "#7aa2f7",
    normal_fg = "#c0caf5",
    normal_bg = "#1e222a",
    terminal = "lime",
    normal = "green",
    command = "red",
    insert = "blue",
    visual = "purple",
    inactive = "#4b5263",
    lsp_fg = "#c0caf5",
    lsp_bg = "#1e222a",
    git_branch_fg = "#c0caf5",
    git_branch_bg = "#1e222a",
    git_added = "#c0caf5",
    git_removed = "#c0caf5",
    git_changed = "#c0caf5",
    git_diff_bg = "#1e222a",
    nav_fg = "#c0caf5",
    nav_bg = "#1e222a",
    scrollbar = "#c0caf5",
    file_info_fg = "#c0caf5",
    file_info_bg = "#1e222a",
    cmd_info_fg = "#c0caf5",
    cmd_info_bg = "#1e222a",
    tabline_bg = "blue",
    tabline_fg = "#00caf5",
    diag_ERROR = "#ff0000",
    diag_WARN = "#ff8800",
    diag_INFO = "#c0caf5",
    diag_HINT = "#c0caf5",
    diagnostics_bg = "#1e222a",
    diagnostics_fg = "#c0caf5",
  })
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
