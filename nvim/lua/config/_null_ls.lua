local M = {}

-- null-ls builtin config guides
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/1533257895fa953c004f88c1d9476af50b721c7d/doc/BUILTINS.md

M.setup = function()
  local null_ls = require('null-ls')
  null_ls.setup({
    debounce = 150,
    save_after_format = false,
    sources = {
      null_ls.builtins.formatting.black,
      -- null_ls.builtins.diagnostics.pylint,
      -- null_ls.builtins.formatting.stylua,
      -- null_ls.builtins.diagnostics.eslint,
      -- null_ls.builtins.completion.spell,
    },
  })
  --  local editorconfig_checker = null_ls.builtins.diagnostics.editorconfig_checker
  --  editorconfig_checker._opts.command = "editorconfig-checker"
  --  null_ls.setup {
  --    sources = {
  --      editorconfig_checker,
  --      null_ls.builtins.diagnostics.actionlint,
  --      null_ls.builtins.diagnostics.codespell,
  --      null_ls.builtins.diagnostics.gitlint,
  --      null_ls.builtins.diagnostics.misspell,
  --      null_ls.builtins.diagnostics.selene,
  --      null_ls.builtins.diagnostics.shellcheck,
  --      null_ls.builtins.diagnostics.yamllint,
  --      null_ls.builtins.formatting.jq,
  --      null_ls.builtins.formatting.ktlint,
  --      null_ls.builtins.formatting.markdownlint,
  --      null_ls.builtins.formatting.prettierd,
  --      null_ls.builtins.formatting.shellharden,
  --      null_ls.builtins.formatting.stylua,
  --      null_ls.builtins.diagnostics.eslint,
  --      null_ls.builtins.completion.spell,
  --    },
  --    -- on_attach = require "wb.lsp.on-attach",
  --  }
end

return M
