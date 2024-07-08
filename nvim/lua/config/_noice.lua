local M = {}
local function myMiniView(pattern, kind, event)
  kind = kind or ""
  return {
    view = "mini",
    filter = {
      event = event and event or "msg_show",
      kind = kind,
      find = pattern,
    },
  }
end

M.setup = function()
  require("noice").setup({
    background_colour = "#000000",
    messages = {
      view_search = "mini",
    },
    routes = {
      {
        view = "mini",
        filter = { event = "msg_showmode" },
      },
      {
        filter = {
          event = "notify",
          warning = true,
          find = "failed to run generator.*is not executable",
        },
        opts = { skip = true },
      },
      {
        view = "mini",
        filter = { event = "msg_show" },
      },
      myMiniView("pcall missing .*"),
      myMiniView("INSERT", "", ""),
      myMiniView("choose"),
      myMiniView("Already at .* change"),
      myMiniView("written"),
      myMiniView("yanked"),
      myMiniView("more lines?"),
      myMiniView("fewer lines?"),
      myMiniView("fewer lines?", "lua_error"),
      myMiniView("change; before"),
      myMiniView("change; after"),
      myMiniView("line less"),
      myMiniView("lines indented"),
      myMiniView("No lines in buffer"),
      myMiniView("search hit .*, continuing at", "wmsg"),
      myMiniView("E486: Pattern not found", "emsg"),
    },
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      signature = {
        enabled = false,
      },
    },
    presets = {
      -- you can enable a preset for easier configuration
      bottom_search = true,      -- use a classic bottom cmdline for search
      command_palette = true,    -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false,        -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true,     -- add a border to hover docs and signature help
    },
  })
end

return M
