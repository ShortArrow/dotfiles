local M = {}

M.is_win_os = function()
  return "Windows_NT" == vim.loop.os_uname().sysname
end

return M
