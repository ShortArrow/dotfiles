local M = {}

-- need `cargo install kakehashi`

M.setup = function()
  if vim.g.__kakehashi_setup_done then return end
  vim.g.__kakehashi_setup_done = true

  local kakehashi_filetypes = {
    "lua",
    "vim",
    "vimdoc",
    "markdown",
    "markdown_inline",
    "json",
    "yaml",
    "toml",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "python",
  }

  local warned = false
  local function warn_missing()
    if warned then return end
    if vim.fn.executable("kakehashi") == 1 then return end
    warned = true
    vim.notify("kakehashi not found in PATH (LSP will not start)", vim.log.levels.WARN)
  end

  local group = vim.api.nvim_create_augroup("KakehashiCheck", { clear = true })
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = group,
    callback = function(args)
      local ft = vim.bo[args.buf].filetype
      for _, v in ipairs(kakehashi_filetypes) do
        if ft == v then
          warn_missing()
          break
        end
      end
    end,
  })

  vim.lsp.config("kakehashi", {
    cmd = { "kakehashi" },
    filetypes = kakehashi_filetypes,
    init_options = {
      autoInstall = true,
    },
  })

  vim.lsp.enable("kakehashi")

  -- Avoid highlight conflicts with built-in treesitter when kakehashi attaches.
  local group_ts = vim.api.nvim_create_augroup("KakehashiTreesitterOff", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group_ts,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == "kakehashi" then
        -- Safely stop treesitter only if it's actually running
        vim.schedule(function()
          local ok, ts = pcall(require, "nvim-treesitter")
          if ok and ts then
            pcall(vim.treesitter.stop, args.buf)
          end
        end)
      end
    end,
  })
end

return M
