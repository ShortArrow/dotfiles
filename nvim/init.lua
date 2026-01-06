-- require "luadebug" : start "127.0.0.1:4980" : event "wait"
vim.g.lazy_ui_active = false

local function usecase_ordinal()
  vim.loader.enable()
  local options = require("my.options")
  options.activate()

  local api = require("my")
  api.lang.python.env()
  api.keymaps.commonmaps_activate()
  require("boot_lazy")

  -- vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = "#FF0000" })
  vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    once = true,
    callback = function()
      require("my.diagnotics")
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyWinEnter",
    callback = function()
      vim.g.lazy_ui_active = true
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyWinLeave",
    callback = function()
      vim.schedule(function()
        vim.g.lazy_ui_active = false
        vim.cmd("redraws!")
      end)
    end,
  })
end

-- Forward deprecated LSP functions to new API
if vim.lsp.buf_get_clients then
  -- Redirect deprecated functions to new API
  vim.lsp.buf_get_clients = function(bufnr)
    bufnr = bufnr or 0
    return vim.lsp.get_clients({ buffer = bufnr })
  end
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
  if vim.g.neovide then
    vim.o.guifont = "JetBrainsMonoNL Nerd Font:h14"
  end
end
