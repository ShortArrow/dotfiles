local config_dir = vim.fn.stdpath("config")
local runtime = vim.api.nvim_get_runtime_file("lua/nvim-treesitter/parsers.lua", true)

local parsers = {}
for _, path in ipairs(runtime) do
  if not path:find(config_dir, 1, true) then
    local ok, mod = pcall(dofile, path)
    if ok and type(mod) == "table" then
      parsers = mod
    end
    break
  end
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
