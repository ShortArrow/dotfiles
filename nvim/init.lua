vim.defer_fn(function()
  local impatient_ok, impatient
  pcall(require, "impatient")
  if not impatient_ok then
    print("pcall missing load impatient.", impatient)
  end
end, 0)

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

  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  local plugins = require("my.plugins").firenvim
  local opts = {}
  require("lazy").setup(plugins, opts)
else
  -- ordinary neovim

  local options = require('my.options')
  options.activate()

  local api = require("my")
  api.lang.python.env()
  api.keymaps.commonmaps_activate()
  require("boot_lazy")

  -- local log_path = vim.fn.stdpath('cache') .. '/packer.nvim.log'
  -- print log_path
  require("config._mason").setup()
  -- vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = "#FF0000" })
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    update_in_insert = false,
    virtual_text = {
      format = function(diagnostic)
        return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
      end,
    },
  })
end
