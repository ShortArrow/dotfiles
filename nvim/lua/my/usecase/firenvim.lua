local M = {}

M.activate = function()
  vim.g.firenvim_config = {
    globalSettigs = {
      alt = "all",
    },
    localSettings = {
      [".*"] = {
        cmdline = "neovim",
        content = "text",
        priority = 0,
        selector = "textarea",
        takeover = "never",
      },
    },
  }

  local setup_firenvim = function()
    vim.bo.filetype = "markdown"
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

  local options = require("my.options")
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
end

return M
