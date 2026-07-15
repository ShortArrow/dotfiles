--- Given: a .cs buffer inside the fixture project. When: LSP clients settle.
--- Then: exactly the servers declared in my.checks attach (one C# server).
--- Skips when omnisharp is not installed (e.g. a runner without mason setup).
--- Run with: nvim --headless "+luafile <this file>"
vim.defer_fn(function()
  local checks = require("my.checks")

  if not vim.uv.fs_stat(vim.fn.stdpath("data") .. "/mason/packages/omnisharp") then
    print("SKIP: omnisharp is not installed via mason")
    vim.cmd("qa!")
    return
  end

  local here = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
  vim.cmd.edit(here .. "/fixture_cs/Program.cs")
  local buf = vim.api.nvim_get_current_buf()

  local attached = vim.wait(120000, function()
    return #vim.lsp.get_clients({ bufnr = buf, name = "omnisharp" }) > 0
  end, 500)
  if not attached then
    print("FAIL: omnisharp did not attach to the fixture buffer within 120s")
    vim.cmd("cq!")
    return
  end
  vim.wait(5000) -- let any unexpected second server show itself

  local results = checks.attached_clients_match(buf, "cs")
  vim.list_extend(results, checks.single_cs_server())
  vim.list_extend(results, checks.blink_lazy_until_insert())

  for _, r in ipairs(results) do
    print((r.ok and "OK: " or "FAIL: ") .. r.msg)
  end
  local failed = vim.iter(results):any(function(r) return not r.ok end)
  vim.cmd(failed and "cq!" or "qa!")
end, 1000)
