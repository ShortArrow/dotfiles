local M = {}

M.setup = function()
  require('toggleterm').setup()
end

-- #region slime
M.set_slime_id = function()
  vim.g.slime_get_jobid = vim.cmd [[echo &channel]]
end

local ok, plugin = pcall(require, 'toggleterm.terminal')
if not ok then
  print('not installed:', plugin)
else
  local Terminal     = plugin.Terminal
  local repl_term    = Terminal:new({ on_open = M.set_slime_id })
  M.toggle_repl_term = function()
    repl_term:toggle()
  end
end

-- #endregion slime

return M
