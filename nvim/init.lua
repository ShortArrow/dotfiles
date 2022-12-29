if vim.g.vscode then
  -- vscode extension
else
  -- ordinary neovim
  if not pcall(require, "impatient") then
    print "Failed to load impatient."
  end

  local options = require('my.options')
  options.activate()

  local ignition = require('my.ignition')
  ignition.load_plugins()

  require('config._mason').start()
  require('config._mason').setup()
  -- local log_path = vim.fn.stdpath('cache') .. '/packer.nvim.log'
  -- print log_path
  ignition.start()
end
