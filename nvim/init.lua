if vim.g.vscode then
  -- vscode extension
elseif vim.g.started_by_firenvim then
  vim.g.firenvim_config = {
    globalSettings = {
      alt = 'all',
    },
    localSettings = {
      [".*"] = {
        cmdline = 'neovim',
        content = 'text',
        priority = 0,
        selector = 'textarea',
        takeover = 'always',
      },
    }
  }
  local options = require('my.options')
  options.activate()

  local _packer = require('packer')
  local function spec(use)
  local depends = plugins.firenvim
    for _, depend in pairs(depends) do
      use(depend)
    end
  end
  _packer.startup {
    spec,
    config = {
      display = {
        open_fn = require("packer.util").float,
      },
      max_jobs = vim.fn.has "win32" == 1 and 5 or nil,
    },
  }

  local ignition = require('my.ignition')
  ignition.start()
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
