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

local plugins = require("my.plugins").ordinalnvim
local opts = {
  ui = {
    icons = {
      cmd = "",
      config = "",
      event = "",
      ft = "",
      init = "",
      import = "",
      keys = "",
      lazy = "  ",
      loaded = "●",
      not_loaded = "○",
      plugin = "",
      runtime = "",
      source = "",
      start = "",
      task = "✔",
      list = { "●", "➜", "★", "‒", },
    },
  },
}

require("lazy").setup(plugins, opts)
-- https://github.com/folke/lazy.nvim/issues/133
local ViewConfig = require("lazy.view.config")
ViewConfig.keys.profile_filter = "<C-f>"
ViewConfig.keys.profile_sort = "<C-s>"
