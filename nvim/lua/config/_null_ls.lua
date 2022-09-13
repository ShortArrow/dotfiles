local ok, null_ls = pcall(require, "null-ls")
local api = require('my/api')
local debugger = api.debugger
if not ok then
  debugger.print('null-ls is null')
  return
end

local M = {}

M.setup = function()
  local editorconfig_checker = null_ls.builtins.diagnostics.editorconfig_checker
  editorconfig_checker._opts.command = "editorconfig-checker"
  null_ls.setup {
    sources = {
      editorconfig_checker,
      null_ls.builtins.diagnostics.actionlint,
      null_ls.builtins.diagnostics.codespell,
      null_ls.builtins.diagnostics.gitlint,
      null_ls.builtins.diagnostics.misspell,
      null_ls.builtins.diagnostics.selene,
      null_ls.builtins.diagnostics.shellcheck,
      null_ls.builtins.diagnostics.yamllint,
      null_ls.builtins.formatting.jq,
      null_ls.builtins.formatting.ktlint,
      null_ls.builtins.formatting.markdownlint,
      null_ls.builtins.formatting.prettierd,
      null_ls.builtins.formatting.shellharden,
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.diagnostics.eslint,
      null_ls.builtins.completion.spell,
    },
    -- on_attach = require "wb.lsp.on-attach",
  }
end

return M
