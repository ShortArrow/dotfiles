-- nvim-treesitter `main` branch is API-incompatible with `master`.
-- See: https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md
--
--   - No `require("nvim-treesitter.configs").setup{...}`.
--   - Parsers: `require("nvim-treesitter").install({...})`.
--   - Highlights / indent: enable per-buffer with `vim.treesitter.start()`
--     and `vim.bo.indentexpr`. Bash-family parsers are skipped because
--     they crash on certain shell-script edge cases on Windows.

local M = {}

local PARSERS = {
  "lua", "vim", "vimdoc", "query",
  "markdown", "markdown_inline",
  "json", "yaml", "toml",
  "html", "css",
  "javascript", "typescript", "tsx",
  "python",
}

local HIGHLIGHT_DISABLE = { bash = true, sh = true, zsh = true, fish = true }

M.setup = function()
  local ts = require("nvim-treesitter")

  -- Pin compilers (matches the previous master-branch behaviour).
  if ts.setup then
    ts.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
  end

  -- Install parsers asynchronously; ignore errors so first launch
  -- doesn't fail when the network is unavailable.
  pcall(function() ts.install(PARSERS) end)

  vim.api.nvim_create_autocmd("FileType", {
    desc = "nvim-treesitter: enable highlight + indent per buffer",
    callback = function(args)
      local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
      if not lang or HIGHLIGHT_DISABLE[lang] then return end

      local ok_parser = pcall(vim.treesitter.get_parser, args.buf, lang)
      if not ok_parser then return end

      pcall(vim.treesitter.start, args.buf, lang)
      -- Indent is opt-in; leave OFF to match previous behaviour.
      -- vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

return M
