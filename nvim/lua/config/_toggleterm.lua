local M = {}

M.setup = function()
  local toggleterm = require("toggleterm")
  toggleterm.setup()

  M.set_slime_id = function()
    vim.g.slime_get_jobid = vim.cmd([[echo &channel]])
  end

  local Terminal = plugin.Terminal
  local repl_term = Terminal:new({ on_open = M.set_slime_id })
  M.toggle_repl_term = function()
    repl_term:toggle()
  end

end

return M
