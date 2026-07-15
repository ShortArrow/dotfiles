--- `:checkhealth my` — machine-state invariants for this config.
--- Assertion bodies live in my.checks; CI runs the same checks headlessly
--- from nvim/tests/.
local M = {}

M.check = function()
  local health = vim.health
  local checks = require("my.checks")

  health.start("my config invariants")

  for _, results in ipairs({
    checks.single_cs_server(),
    checks.lsp_log_size(),
    checks.no_startup_errors(),
  }) do
    for _, r in ipairs(results) do
      if r.ok then health.ok(r.msg) else health.error(r.msg) end
    end
  end

  health.start("attached LSP clients (current buffers)")
  local reported = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local ft = vim.bo[buf].filetype
      if checks.expected_lsp_clients[ft] then
        reported = true
        for _, r in ipairs(checks.attached_clients_match(buf, ft)) do
          if r.ok then health.ok(r.msg) else health.error(r.msg) end
        end
      end
    end
  end
  if not reported then
    health.info("no open buffer has a declared LSP expectation (see my.checks.expected_lsp_clients)")
  end
end

return M
