local M = {}

M.activate = function()
  vim.g.mapleader = " "
  vim.opt.virtualedit = "block"
  local vscode = require("vscode")

  -- Set VSCode command to Neovim keymap
  local function action(cmd)
    return function()
      print("action", cmd)
      vscode.action(cmd)
    end
  end

  local keymap = function(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs)
  end

  ---This is keymap of commentout
  keymap({ "x", "o", "n" }, "gc", "<Plug>VSCodeCommentary")
  keymap({ "n" }, "gcc", "<Plug>VSCodeCommentaryLine")
  keymap("n", "<Leader>tr", action("workbench.actions.view.problems"))
  keymap("n", "<Leader>tt", action("workbench.action.terminal.focus"))
  keymap("n", "<Leader>ld", action("editor.action.goToDeclaration"))
  --vim.keymap.set("n", "<Leader>lh", action("editor.action.showHover"))
  keymap("n", "<Leader>lf", action("editor.action.formatDocument"))
  keymap("n", "<Leader>ln", action("editor.action.rename"))
  keymap("n", "<Leader>lb", action("workbench.action.navigateBack"))
  keymap("n", "<Leader>wl", action("workbench.action.focusRightGroup"))
  keymap("n", "<Leader>wh", action("workbench.action.focusLeftGroup"))
  keymap("n", "<Leader>wj", action("workbench.action.focusLastEditorGroup"))
  keymap("n", "<Leader>wk", action("workbench.action.focusFirstSideEditor"))
  keymap("n", "<Leader>wb", action("workbench.action.focusStatusBar"))
  keymap("n", "<Leader>ws", action("workbench.action.focusSideBar"))
  keymap("n", "<Leader>wr", action("workbench.debug.action.focusRepl"))
  keymap("n", "<Leader>fb", action("workbench.action.quickOpen"))
  keymap("n", "<Leader>wd", action("workbench.view.debug"))
  keymap("n", "<Leader>ff", action("workbench.view.explorer"))
  keymap("n", "<Leader>lg", action("workbench.view.scm"))
  keymap("n", "<Leader>fg", action("workbench.action.replaceInFiles"))
  keymap("n", "<Leader>bp", "<cmd>bp<CR>")
  keymap("n", "<Leader>bn", "<cmd>bn<CR>")
  -- Copy to clipboard
  keymap("v", "<Leader>y", '"+y')
  keymap("n", "<Leader>Y", '"+yg_')
  keymap("n", "<Leader>y", '"+y')
  keymap("n", "<Leader>yy", '"+yy')
  -- Paste from clipboard
  keymap("n", "<Leader>p", '"+p')
  keymap("n", "<Leader>P", '"+P')
  keymap("v", "<Leader>p", '"+p')
  keymap("v", "<Leader>P", '"+P')
end

return M
