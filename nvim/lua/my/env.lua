local M = {}

M.is_win_os = function()
  return "Windows_NT" == vim.loop.os_uname().sysname
end
M.is_firenvim = function()
  return vim.g.started_by_firenvim
end

return M
