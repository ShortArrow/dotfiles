if not pcall(require, "impatient") then
  print "Failed to load impatient."
end

if vim.g.vscode then
  -- vscode extension
  print('load vscode extension config')
elseif 0 ~= vim.fn.exists('g:started_by_firenvim') then
  -- general config for firenvim
  print('load firenvim config')
  vim.g.firenvim_config = {
    globalSettigs = {
      alt = 'all',
    },
    localSettings = {
      [".*"] = {
        cmdline = 'neovim',
        content = 'text',
        priority = 0,
        selector = 'textarea',
        takeover = 'never',
      },
    }
  }

  local setup_firenvim = function()
    vim.bo.filetype = 'markdown'
    vim.wo.number = false
    vim.go.laststatus = 0
    vim.go.showtabline = 0
  end

  local firenvimGrp = vim.api.nvim_create_augroup("firenvim", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "text" },
    group = firenvimGrp,
    callback = setup_firenvim,
  })
  local options = require('my.options')
  options.activate()

  local _packer = require('packer')
  local function spec(use)
    local plugins = require('my.plugins')
    local depends = plugins.firenvim
    for _, depend in pairs(depends) do
      use(depend)
    end
  end

  _packer.startup {
    spec,
    config = {
      max_jobs = vim.fn.has "win32" == 1 and 5 or nil,
    },
  }

  local ignition = require('my.ignition')
  ignition.start()
else
  -- ordinary neovim
  local options = require('my.options')
  options.activate()

  local ignition = require('my.ignition')
  ignition.load_plugins()

  require('config._mason').start()
  require('config._mason').setup()
  -- local log_path = vim.fn.stdpath('cache') .. '/packer.nvim.log'
  -- print log_path

  ignition.start()
  -- vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = "#FF0000" })
end
