local M = {}

M.setup = function()
  local status_ok, rust_tools = pcall(require, "rust-tools")
  if not status_ok then
    return
  end

  local opts = {
      tools = {
          executor = require("rust-tools/executors").termopen, -- can be quickfix or termopen
          reload_workspace_from_cargo_toml = true,
          inlay_hints = {
              auto = true,
              only_current_line = false,
              show_parameter_hints = true,
              parameter_hints_prefix = "<-",
              other_hints_prefix = "=>",
              max_len_align = false,
              max_len_align_padding = 1,
              right_align = false,
              right_align_padding = 7,
              highlight = "Comment",
          },
          hover_actions = {
              border = {
                      { "╭", "FloatBorder" },
                      { "─", "FloatBorder" },
                      { "╮", "FloatBorder" },
                      { "│", "FloatBorder" },
                      { "╯", "FloatBorder" },
                      { "─", "FloatBorder" },
                      { "╰", "FloatBorder" },
                      { "│", "FloatBorder" },
              },
              auto_focus = true,
          },
      },
      server = {
          settings = {
              ["rust-analyzer"] = {
                  checkOnSave = {
                      command = "clippy"
                  }
              }
          },
      },
  }
  --local extension_path = vim.fn.expand "~/" .. ".vscode/extensions/vadimcn.vscode-lldb-1.7.3/"

  --local codelldb_path = extension_path .. "adapter/codelldb"
  --local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"

  --opts.dap = {
  --        adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
  --}
  rust_tools.setup(opts)
end

return M
