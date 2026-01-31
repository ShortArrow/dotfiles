local M = {}

M.setup = function()
  require("nvim-treesitter.install").compilers = { "zig", "clang", "gcc" }
  require("nvim-treesitter.configs").setup({
    auto_install = false,
    modules = {},  -- Add explicit modules field to prevent nil error
    highlight = {
      enable = true,
      -- Disable for shell scripts due to parser issues
      disable = { "bash", "sh", "zsh", "fish" },
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = false,
      disable = {},
    },
    ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      "markdown",
      "markdown_inline",
      "json",
      "yaml",
      "toml",
      "html",
      "css",
      "javascript",
      "typescript",
      "tsx",
      "python",
      -- bash excluded due to errors
    },
  })
end

return M