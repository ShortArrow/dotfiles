-- Shadows nvim-treesitter.parsers to add has_parser, which vim-illuminate
-- calls from the master-branch API. Plugins require this module before
-- nvim-treesitter is on the runtimepath, so the plugin's entries are
-- fetched on first lookup instead of at require time.
local config_dir = vim.fs.normalize(vim.fn.stdpath("config")):lower() .. "/"

-- stdpath("data") ("nvim-data") shares a string prefix with the config dir
-- ("nvim"), so compare whole path segments.
local function in_config_dir(path)
  return vim.startswith(vim.fs.normalize(path):lower(), config_dir)
end

local function find_upstream()
  for _, path in ipairs(vim.api.nvim_get_runtime_file("lua/nvim-treesitter/parsers.lua", true)) do
    if not in_config_dir(path) then
      local ok, mod = pcall(dofile, path)
      return ok and type(mod) == "table" and mod or nil
    end
  end
end

local parsers = {}

local function adopt_upstream()
  local upstream = find_upstream()
  if not upstream then return false end
  for k, v in pairs(upstream) do
    if rawget(parsers, k) == nil then rawset(parsers, k, v) end
  end
  setmetatable(parsers, nil)
  return true
end

if not adopt_upstream() then
  setmetatable(parsers, {
    __index = function(t, k)
      if adopt_upstream() then return rawget(t, k) end
    end,
  })
end

parsers.has_parser = function(lang)
  if not lang or lang == "" then return false end

  local ok_cfg, cfg = pcall(require, "nvim-treesitter.config")
  local parser_dir = ok_cfg and cfg.get_install_dir("parser") or (vim.fn.stdpath("data") .. "/site/parser")

  local exts = { ".so", ".dylib", ".dll" }
  for _, ext in ipairs(exts) do
    if vim.uv.fs_stat(parser_dir .. "/" .. lang .. ext) then
      return true
    end
  end

  for _, ext in ipairs(exts) do
    local runtime = vim.api.nvim_get_runtime_file("parser/" .. lang .. ext, true)
    if runtime and #runtime > 0 then
      return true
    end
  end

  return false
end

return parsers
