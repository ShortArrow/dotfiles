local is_debug = true

local M = {
  print = function(message)
    if is_debug then
      print(message)
    end
  end
}

return M
