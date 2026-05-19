local config_dir = vim.fn.stdpath("config")
local runtime = vim.api.nvim_get_runtime_file("lua/nvim-treesitter/query.lua", true)

local query = {}
for _, path in ipairs(runtime) do
  if not path:find(config_dir, 1, true) then
    local ok, mod = pcall(dofile, path)
    if ok and type(mod) == "table" then
      query = mod
    end
    break
  end
end

if query and not query.has_locals then
  query.has_locals = function(lang)
    if not lang or lang == "" then return false end
    local ok_get, q = pcall(query.get, lang, "locals")
    return ok_get and q ~= nil
  end
end

return query
