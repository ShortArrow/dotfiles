M = {}

local vscode = require("vscode")

local function action(cmd)
  return function()
    vscode.action(cmd)
  end
end

M.keymap_activate = function()
  ---This is keymap of commentout
  vim.keymap.set({ "x", "o", "n" }, "gc", "<Plug>VSCodeCommentary")
  vim.keymap.set({ "n" }, "gcc", "<Plug>VSCodeCommentaryLine")

  -- Set VSCode command to Neovim keymap
  vim.keymap.set("n", "<Leader>ld", action("editor.action.goToDeclaration"))
  --vim.keymap.set("n", "<Leader>lh", action("editor.action.showHover"))
  vim.keymap.set("n", "<Leader>lf", action("editor.action.formatDocument"))
  vim.keymap.set("n", "<Leader>ln", action("editor.action.rename"))
  vim.keymap.set("n", "<Leader>lb", action("workbench.action.navigateBack"))
  vim.keymap.set("n", "<Leader>s", action("workbench.action.files.save"))
  vim.keymap.set("n", "<Leader>wl", action("workbench.action.focusRightGroup"))
  vim.keymap.set("n", "<Leader>wh", action("workbench.action.focusLeftGroup"))
  vim.keymap.set("n", "<Leader>wj", action("workbench.action.focusBellowGroup"))
  vim.keymap.set("n", "<Leader>wk", action("workbench.action.focusAboveGroup"))
  vim.keymap.set("n", "<Leader>ff", action("workbench.view.explorer"))
  vim.keymap.set("n", "<Leader>lg", action("workbench.view.scm"))
  vim.keymap.set("n", "<Leader>fg", action("workbench.action.replaceInFiles"))
  vim.keymap.set("n", "<Leader>bp", "<cmd>bp<CR>")
  vim.keymap.set("n", "<Leader>bn", "<cmd>bn<CR>")
end

---This function is must be called when the mode changes
local function changeThemeOnModeChange()
  local mode = vim.api.nvim_get_mode().mode
  if mode == "i" then                                     -- insert mode
    vim.fn.VSCodeNotify("nvim-theme.insert")
  elseif mode == "R" or mode == "r" then                  -- replace mode
    vim.fn.VSCodeNotify("nvim-theme.replace")
  elseif mode == "v" or mode == "V" or mode == "\x16" then -- visual mode
    vim.fn.VSCodeNotify("nvim-theme.visual")
  else                                                    -- normal mode
    vim.fn.VSCodeNotify("nvim-theme.normal")
  end
end

---This autocmd group is used to change the theme when the mode changes
local augroup = vim.api.nvim_create_augroup("ThemeChangeOnMode", { clear = true })

M.ui_setup = function()
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
end

return M
