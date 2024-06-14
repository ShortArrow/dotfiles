local function usecase_vscode()
  local vscode = require("vscode")
  ---This function is must be called when the mode changes
  local function changeThemeOnModeChange()
    local mode = vim.api.nvim_get_mode().mode
    if mode == "i" then                                    -- insert mode
      vim.fn.VSCodeNotify("nvim-theme.insert")
    elseif mode == "R" or mode == "r" then                 -- replace mode
      vim.fn.VSCodeNotify("nvim-theme.replace")
    elseif mode == "v" or mode == "V" or mode == "\x16" then -- visual mode
      vim.fn.VSCodeNotify("nvim-theme.visual")
    else                                                   -- normal mode
      vim.fn.VSCodeNotify("nvim-theme.normal")
    end
  end

  ---This autocmd group is used to change the theme when the mode changes
  local augroup = vim.api.nvim_create_augroup("ThemeChangeOnMode", { clear = true })

  ---Add an autocmd to the ModeChanged event to change the theme when the mode changes
  vim.api.nvim_create_autocmd({ "ModeChanged" }, {
    pattern = "*",
    callback = changeThemeOnModeChange,
    group = augroup,
  })

  ---Add an autocmd to the InsertEnter, InsertLeave, and VimEnter events to change the theme when the mode changes
  ---@note some mode changes cannot be captured by the ModeChanged event, so we need to capture them with specific events
  vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave", "VimEnter" }, {
    pattern = "*",
    callback = changeThemeOnModeChange,
    group = augroup,
  })

  ---This function is used to change the theme when the cursor moves
  vim.api.nvim_set_keymap("x", "gc", "<Plug>VSCodeCommentary", { noremap = false, silent = true })
  vim.api.nvim_set_keymap("n", "gc", "<Plug>VSCodeCommentary", { noremap = false, silent = true })
  vim.api.nvim_set_keymap("o", "gc", "<Plug>VSCodeCommentary", { noremap = false, silent = true })
  vim.api.nvim_set_keymap("n", "gcc", "<Plug>VSCodeCommentaryLine", { noremap = false, silent = true })
  -- Set VSCode command to Neovim keymap
  local action = function(cmd)
    return function()
      vscode.action(cmd)
    end
  end
  vim.keymap.set("n", "<space>d", action("editor.action.goToDeclaration"))
  vim.keymap.set("n", "<space>b", action("workbench.action.navigateBack"))
  vim.keymap.set("n", "<space>h", action("editor.action.showHover"))
  vim.keymap.set("n", "<space>f", action("editor.action.formatDocument"))
  vim.keymap.set("n", "<space>s", action("workbench.action.files.save"))
end

local function usecase_firenvim()
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
  usecase_vscode()
elseif 0 ~= vim.fn.exists("g:started_by_firenvim") then
  -- general config for firenvim
  print("load firenvim config")
  usecase_firenvim()
else
  -- ordinary neovim
  usecase_ordinal()
end
