local M = {}

M.activate = function()
  vim.g.mapleader = " "
  local vscode = require("vscode")
  ---This function is must be called when the mode changes
  local function changeThemeOnModeChange()
    local mode = vim.api.nvim_get_mode().mode
    if mode == "i" then                                      -- insert mode
      vim.fn.VSCodeNotify("nvim-theme.insert")
    elseif mode == "R" or mode == "r" then                   -- replace mode
      vim.fn.VSCodeNotify("nvim-theme.replace")
    elseif mode == "v" or mode == "V" or mode == "\x16" then -- visual mode
      vim.fn.VSCodeNotify("nvim-theme.visual")
    else                                                     -- normal mode
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

  -- Set VSCode command to Neovim keymap
  local function action(cmd)
    return function()
      print("action", cmd)
      vscode.action(cmd)
    end
  end

  local k = function(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs)
  end

  ---This is keymap of commentout
  k({ "x", "o", "n" }, "gc", "<Plug>VSCodeCommentary")
  k({ "n" }, "gcc", "<Plug>VSCodeCommentaryLine")
  k("n", "<Leader>tr", action("workbench.actions.view.problems"))
  k("n", "<Leader>tt", action("workbench.action.terminal.toggleTerminal"))
  k("n", "<Leader>ld", action("editor.action.goToDeclaration"))
  --vim.keymap.set("n", "<Leader>lh", action("editor.action.showHover"))
  k("n", "<Leader>lf", action("editor.action.formatDocument"))
  k("n", "<Leader>ln", action("editor.action.rename"))
  k("n", "<Leader>lb", action("workbench.action.navigateBack"))
  k("n", "<Leader>s", action("workbench.action.files.save"))
  k("n", "<Leader>wl", action("workbench.action.focusRightGroup"))
  k("n", "<Leader>wh", action("workbench.action.focusLeftGroup"))
  k("n", "<Leader>wj", action("workbench.action.focusBellowGroup"))
  k("n", "<Leader>wk", action("workbench.action.focusAboveGroup"))
  k("n", "<Leader>ff", action("workbench.view.explorer"))
  k("n", "<Leader>lg", action("workbench.view.scm"))
  k("n", "<Leader>fg", action("workbench.action.replaceInFiles"))
  k("n", "<Leader>bp", "<cmd>bp<CR>")
  k("n", "<Leader>bn", "<cmd>bn<CR>")
  -- Copy to clipboard
  k("v", "<Leader>y", '"+y')
  k("n", "<Leader>Y", '"+yg_')
  k("n", "<Leader>y", '"+y')
  k("n", "<Leader>yy", '"+yy')
  -- Paste from clipboard
  k("n", "<Leader>p", '"+p')
  k("n", "<Leader>P", '"+P')
  k("v", "<Leaderp", '"+p')
  k("v", "<LeaderP", '"+P')
end

return M
