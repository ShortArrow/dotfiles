-- Rescue editor. Launched as `NVIM_APPNAME=nvim-rescue nvim`, which makes
-- Neovim read this directory instead of the main `nvim/src` config and keep
-- its state under a separate data directory. Nothing here can be affected by
-- a broken main config, and nothing here writes back into it.
--
-- The constraint that shapes this file: it has to work when other things do
-- not. So it uses no plugins and no plugin manager — Neovim 0.11+ ships LSP
-- configuration, LSP completion and Treesitter highlighting in core, which
-- covers everything this needs to be more useful than plain vim. There is no
-- network step and no bootstrap; cloning the repo is the whole install.

if vim.fn.has("nvim-0.11") == 0 then
  vim.notify("nvim-rescue expects Neovim 0.11+; falling back to defaults", vim.log.levels.WARN)
  return
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Options ------------------------------------------------------------------

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.termguicolors = true
opt.showmode = false

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

opt.undofile = true
opt.swapfile = false
opt.updatetime = 250

opt.splitright = true
opt.splitbelow = true

opt.wildmode = "longest:full,full"
opt.completeopt = "menuone,noselect,popup"

-- Make it obvious which editor this is. Confusing the rescue instance for the
-- main one while repairing the main one is the failure this guards against.
opt.statusline = table.concat({
  "%#WarningMsg# RESCUE %* ",
  "%f %m%r",
  "%=",
  "%{&filetype} ",
  "%l:%c ",
})

-- Keymaps ------------------------------------------------------------------
--
-- Deliberately few. This config is used rarely and under pressure, so it stays
-- close to stock Neovim rather than teaching a second set of habits.

local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic under cursor" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })

-- Highlight on yank so a blind paste is verifiable.
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- Treesitter ---------------------------------------------------------------
--
-- Only for parsers Neovim ships with; nothing is downloaded. Anything else
-- falls back to regex syntax highlighting, which is fine.

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- LSP ----------------------------------------------------------------------
--
-- Servers are declared unconditionally but enabled only when their executable
-- resolves, so a machine missing any of them starts clean instead of throwing
-- on every buffer.

local servers = {
  luals = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
      },
    },
  },
  rust_analyzer = {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", ".git" },
  },
  clangd = {
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp" },
    root_markers = { "compile_commands.json", ".clangd", ".git" },
  },
  gopls = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod" },
    root_markers = { "go.work", "go.mod", ".git" },
  },
  pyright = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", ".git" },
  },
  ts_ls = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_markers = { "tsconfig.json", "package.json", ".git" },
  },
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  if vim.fn.executable(config.cmd[1]) == 1 then
    vim.lsp.enable(name)
  end
end

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { border = "rounded", source = true },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local opts = { buffer = args.buf }

    map("n", "grn", vim.lsp.buf.rename, opts)
    map("n", "gra", vim.lsp.buf.code_action, opts)
    map("n", "grr", vim.lsp.buf.references, opts)
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)

    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})
