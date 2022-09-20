local M = {}

M.sumneko_lua = {
  Lua = {
    diagnostics = { globals = { 'vim' } },
    completion = { callSnippet = "Replace" },
    workspace = { library = vim.api.nvim_get_runtime_file("", true) },
    telemetry = { enable = false },
    runtime = {
      version = "LuaJIT",
      path = { "?.lua", "?/init.lua" },
    },
  }
}

return M
