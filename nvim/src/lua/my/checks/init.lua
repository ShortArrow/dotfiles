--- Shared invariant checks for this Neovim config.
--- Each check returns a list of { ok = boolean, msg = string }.
--- Consumed by two runners: `:checkhealth my` (lua/my/health.lua) and the
--- headless CI probes under nvim/tests/.
local M = {}

local function result(ok, msg)
  return { ok = ok, msg = msg }
end

--- Exactly one C# language server may be installed; several servers attach
--- to the same buffer at once, multiplying solution loads and freezing the
--- UI thread until first highlight.
M.single_cs_server = function()
  local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
  local cs_servers = { "omnisharp", "omnisharp-mono", "csharp-language-server" }
  local installed = {}
  for _, name in ipairs(cs_servers) do
    if vim.uv.fs_stat(mason_packages .. "/" .. name) then
      table.insert(installed, name)
    end
  end
  if #installed <= 1 then
    return { result(true, "C# language servers installed: " .. (installed[1] or "none")) }
  end
  return { result(false, table.concat(installed, ", ")
    .. " are all installed; every one of them attaches to each .cs buffer."
    .. " Keep omnisharp and uninstall the rest.") }
end

--- The clients expected to attach for a given filetype. A buffer of that
--- filetype must already be open when this runs.
M.expected_lsp_clients = {
  cs = { "omnisharp" },
  lua = { "lua_ls" },
}

--- Ignored when comparing attached clients (not tied to one language).
M.lsp_client_noise = { copilot = true, ["null-ls"] = true, ["GitHub Copilot"] = true }

M.attached_clients_match = function(bufnr, filetype)
  local expected = M.expected_lsp_clients[filetype]
  if not expected then
    return { result(true, "no expectation declared for filetype " .. filetype) }
  end
  local actual = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if not M.lsp_client_noise[c.name] then
      table.insert(actual, c.name)
    end
  end
  table.sort(actual)
  local want = vim.deepcopy(expected)
  table.sort(want)
  local ok = vim.deep_equal(actual, want)
  local msg = ("filetype %s: attached [%s], expected [%s]"):format(
    filetype, table.concat(actual, ","), table.concat(want, ","))
  return { result(ok, msg) }
end

--- A multi-megabyte lsp.log means a server floods WARN messages; every line
--- is written synchronously on the UI thread while editing.
M.lsp_log_size = function()
  local max_bytes = 5 * 1024 * 1024
  local path = vim.lsp.get_log_path()
  local stat = vim.uv.fs_stat(path)
  local size = stat and stat.size or 0
  return { result(size < max_bytes,
    ("lsp.log is %.1f MB (%s)"):format(size / 1024 / 1024, path)) }
end

--- Loading the config must not leave error messages behind.
M.no_startup_errors = function()
  local messages = vim.fn.execute("messages")
  local ok = not messages:match("E%d+:") and not messages:match("stack traceback")
  return { result(ok, ok and "no error messages on startup"
    or "startup left error messages:\n" .. messages) }
end

return M
