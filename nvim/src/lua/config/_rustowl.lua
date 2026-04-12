-- rustowl plugin wiring.
--
-- Called from plugins.lua as `init = get_config("_rustowl").init`. This
-- module owns:
--   * a Neovim 0.12+ compatibility shim for `vim.highlight.range`
--   * the `vim.g.rustowl` configuration table (must be set before
--     rustowl's ftplugin/rust.lua runs, hence `init`, not `opts`)
--   * the LSP `on_attach` handler that registers buffer-local key
--     maps and installs the auto-highlight poller
--
-- Keep the plugins.lua entry short: this file is where the logic lives.

local M = {}

---Compatibility shim for Neovim 0.12+: rustowl v0.3.4 still calls
---`vim.highlight.range`, which was removed in 0.12 (moved to
---`vim.hl.range`). Without this shim the call throws inside an LSP
---response callback and the exception is swallowed, so decorations
---are returned by the server but nothing is drawn.
local function install_highlight_shim()
  if type(vim.hl) == "table" and type(vim.hl.range) == "function" then
    if type(vim.highlight) ~= "table" then
      vim.highlight = {}
    end
    if type(vim.highlight.range) ~= "function" then
      vim.highlight.range = vim.hl.range
    end
  end
end

---Fake a textDocument/didSave so rustowl v0.3.4 starts analysis
---without requiring an actual buffer write. rustowl v0.3.4 has no
---`rustowl/analyze` custom method — that was added in v1.0.0-rc.1 —
---so the `did_save` handler in its LSP backend is the only external
---knob for kicking analysis. The notify form takes no response and
---therefore never surfaces a Method-not-found error.
---@param bufnr integer
local function kick_analysis(bufnr)
  local lsp_ok, lsp = pcall(require, "rustowl.lsp")
  if not lsp_ok then
    vim.notify("rustowl.lsp require failed", vim.log.levels.ERROR)
    return
  end
  local clients = lsp.get_rustowl_clients({ bufnr = bufnr })
  if #clients == 0 then
    vim.notify("rustowl: no LSP client attached to buffer " .. bufnr,
      vim.log.levels.WARN)
    return
  end
  local params = { textDocument = { uri = vim.uri_from_bufnr(bufnr) } }
  for _, c in ipairs(clients) do
    pcall(function() c:notify("textDocument/didSave", params) end)
  end
end

---LSP on_attach: register buffer-local key maps and install the
---auto-highlight poller that redraws once analysis completes.
---@param _ vim.lsp.Client
---@param bufnr integer
local function on_attach(_, bufnr)
  local status = require("config._rustowl_status")

  -- Redraw once analysis finishes on the first post-save render,
  -- so the user doesn't need to wiggle the cursor to see highlights.
  status.install_autohighlight(bufnr)

  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("<Leader>ro", function() require("rustowl").toggle(bufnr) end,
    "Toggle RustOwl")
  map("<Leader>re", function()
    require("rustowl").enable(bufnr)
    kick_analysis(bufnr)
    status.kick_when_ready(bufnr)
  end, "Enable RustOwl (without :w)")
  map("<Leader>rd", function() require("rustowl").disable(bufnr) end,
    "Disable RustOwl")
  map("<Leader>rs", function() status.toggle() end,
    "Toggle RustOwl status window")
  map("<Leader>ry", function() status.yank() end,
    "Yank RustOwl status to clipboard")
end

---lazy.nvim `init` callback. Runs *before* the plugin is loaded, so
---vim.g.rustowl is guaranteed to be set by the time rustowl's
---ftplugin/rust.lua runs `require('rustowl.config')` — which reads
---vim.g.rustowl exactly once and then caches it.
function M.init()
  install_highlight_shim()

  -- Load the status helper eagerly so its :RustowlStatus /
  -- :RustowlStatusYank user commands are registered at startup,
  -- not only after the first rustowl LspAttach.
  pcall(require, "config._rustowl_status")

  vim.g.rustowl = {
    auto_attach = true,
    auto_enable = false,
    idle_time = 500,
    -- Plain underline instead of undercurl: undercurl needs the
    -- terminal to advertise Smulx/Setulc via terminfo (so the
    -- per-category borrow/lifetime colors can be emitted with
    -- SGR 58). Windows + wezterm + Neovim 0.12 could not be coaxed
    -- into a working combination during setup; SGR 4 underline
    -- works unconditionally. Trade-off: all categories share one
    -- color (the text foreground) instead of rustowl's palette.
    highlight_style = "underline",
    client = { on_attach = on_attach },
  }
end

return M
