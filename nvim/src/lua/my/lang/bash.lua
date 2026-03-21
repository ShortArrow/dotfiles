local M = {}

M.bridge = {
  server = "bash-language-server",
  cmd = { "bash-language-server", "start" },
  languages = { "bash" },
}

return M
