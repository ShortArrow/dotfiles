local M = {}

M.is_debug = false

M.print = function(message)
  if M.is_debug then
    print(message)
  end
end

return M
