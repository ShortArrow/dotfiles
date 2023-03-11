if vim.g.vscode then
  -- vscode extension
  print("load vscode extension config")
  -- THEME CHANGER

  function SetCursorLineNrColorInsert(mode)
    -- Insert mode: blue
    if mode == "i" then
      vim.api.nvim_call_function("VSCodeNotify", { "nvim-theme.insert" })
      -- Replace mode: red
    elseif mode == "r" then
      vim.api.nvim_call_function("VSCodeNotify", { "nvim-theme.replace" })
    end
  end

  function SetCursorLineNrColorVisual()
    vim.api.nvim_command("set updatetime=0")
    vim.api.nvim_call_function("VSCodeNotify", { "nvim-theme.visual" })
  end

  vim.api.nvim_set_keymap(
    "v",
    "<SID>SetCursorLineNrColorVisual",
    "<expr> v:lua.SetCursorLineNrColorVisual()",
    { silent = true }
  )
  vim.api.nvim_set_keymap(
    "n",
    "v<SID>SetCursorLineNrColorVisual",
    "<script> v<SID>SetCursorLineNrColorVisual()",
    { silent = true }
  )
  vim.api.nvim_set_keymap(
    "n",
    "V<SID>SetCursorLineNrColorVisual",
    "<script> V<SID>SetCursorLineNrColorVisual()",
    { silent = true }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<C-v><SID>SetCursorLineNrColorVisual",
    "<script> <C-v><SID>SetCursorLineNrColorVisual()",
    { silent = true }
  )

  vim.api.nvim_exec(
    [[
augroup CursorLineNrColorSwap
autocmd!
autocmd InsertEnter * call v:lua.SetCursorLineNrColorInsert(vim.fn.expand('<a:insertmode>'))
autocmd InsertLeave * call vim.api.nvim_call_function('VSCodeNotify', {'nvim-theme.normal'})
autocmd CursorHold * call vim.api.nvim_call_function('VSCodeNotify', {'nvim-theme.normal'})
augroup END
]],
    false
  )
elseif 0 ~= vim.fn.exists("g:started_by_firenvim") then
  -- general config for firenvim
  print("load firenvim config")
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
else
  -- ordinary neovim

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
