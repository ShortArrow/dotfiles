local M = {}

-- Configure vim-illuminate to avoid deprecated Treesitter APIs on nightly (0.11)
M.setup = function()
  local ok, illuminate = pcall(require, "illuminate")
  if not ok then
    return
  end

  illuminate.configure({
    providers = { "lsp", "regex" }, -- disable treesitter provider to avoid get_matches error
    delay = 200,
    filetypes_denylist = {
      "NvimTree",
      "neo-tree",
      "trouble",
      "lazy",
      "help",
    },
    modes_denylist = { "t" },
  })
end

return M
