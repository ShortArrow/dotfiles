local M = {}

M.is_function = function(stuff)
  return type(stuff) == 'function'
end

M.is_boolean = function(stuff)
  return type(stuff) == 'boolean'
end

return M
