local is_debug = true

local M = {
  print = function(message)
    if is_debug then
      print(message)
    end
  end,
  is_debug = is_debug,
}

return M
