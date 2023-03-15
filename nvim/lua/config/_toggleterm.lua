local M = {}

M.set_slime_id = function()
  vim.g.slime_get_jobid = vim.cmd([[echo &channel]])
end

M.setup = function()
  local toggleterm = require("toggleterm")
  toggleterm.setup()
end

M.toggle_repl_term = function()
  local Terminal = require("toggleterm.terminal").Terminal
  local repl_term = Terminal:new({ on_open = M.set_slime_id })
  repl_term:toggle()
end

return M
