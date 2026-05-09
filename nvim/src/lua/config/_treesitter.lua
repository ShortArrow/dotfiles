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

local function missing_parsers()
  local installed = {}
  for _, name in ipairs(vim.api.nvim_get_runtime_file("parser/*.so", true)) do
    installed[vim.fn.fnamemodify(name, ":t:r")] = true
  end
  local missing = {}
  for _, lang in ipairs(PARSERS) do
    if not installed[lang] then table.insert(missing, lang) end
  end
  return missing
end

M.setup = function()
  local ts = require("nvim-treesitter")

  if ts.setup then
    ts.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
  end

  -- :TSInstallMyParsers — install only the languages we declare here.
  -- Run once after the plugin loads (or after Neovim upgrade).
  vim.api.nvim_create_user_command("TSInstallMyParsers", function()
    local missing = missing_parsers()
    if #missing == 0 then
      vim.notify("treesitter: all declared parsers already installed", vim.log.levels.INFO)
      return
    end
    vim.notify("treesitter: installing " .. table.concat(missing, ", "), vim.log.levels.INFO)
    ts.install(missing)
  end, { desc = "Install parsers declared in _treesitter.lua" })

  vim.api.nvim_create_autocmd("FileType", {
    desc = "nvim-treesitter: enable highlight per buffer",
    callback = function(args)
      local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
      if not lang or HIGHLIGHT_DISABLE[lang] then return end

      local ok_parser = pcall(vim.treesitter.get_parser, args.buf, lang)
      if not ok_parser then return end

      pcall(vim.treesitter.start, args.buf, lang)
    end,
  })
end

return M
