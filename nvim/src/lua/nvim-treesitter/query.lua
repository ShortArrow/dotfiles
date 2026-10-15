local config_dir = vim.fs.normalize(vim.fn.stdpath("config")):lower() .. "/"

-- stdpath("data") ("nvim-data") shares a string prefix with the config dir
-- ("nvim"), so compare whole path segments.
local function in_config_dir(path)
  return vim.startswith(vim.fs.normalize(path):lower(), config_dir)
end
local runtime = vim.api.nvim_get_runtime_file("lua/nvim-treesitter/query.lua", true)

local query = {}
for _, path in ipairs(runtime) do
  if not in_config_dir(path) then
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
