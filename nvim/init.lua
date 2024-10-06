local function usecase_ordinal()
  local options = require("my.options")
  options.activate()

  local api = require("my")
  api.lang.python.env()
  api.keymaps.commonmaps_activate()
  require("boot_lazy")

  -- local log_path = vim.fn.stdpath('cache') .. '/packer.nvim.log'
  -- print log_path
  require("config._mason").setup()
  -- vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = "#FF0000" })
  require("my.diagnotics")
end

if vim.g.vscode then
  -- vscode extension
  print("load vscode extension config")
  local vscode = require("my.usecase.vscode")
  vscode.activate()
elseif 0 ~= vim.fn.exists("g:started_by_firenvim") then
  -- general config for firenvim
  print("load firenvim config")
  local firenvim = require("my.usecase.firenvim")
  firenvim.activate()
else
  -- ordinary neovim
  usecase_ordinal()
end
