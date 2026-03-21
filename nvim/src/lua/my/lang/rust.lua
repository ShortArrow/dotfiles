local M   = {}

M.bridge = {
  server = "rust-analyzer",
  cmd = { "rust-analyzer" },
  languages = { "rust" },
}

M.neotest = {
  args = { "--no-capture" },
}

return M
