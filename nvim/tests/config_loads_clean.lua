--- Given: the full config. When: Neovim finished starting. Then: no error
--- messages were emitted. Run with: nvim --headless "+luafile <this file>"
vim.defer_fn(function()
  local results = require("my.checks").no_startup_errors()
  for _, r in ipairs(results) do
    print((r.ok and "OK: " or "FAIL: ") .. r.msg)
  end
  local failed = vim.iter(results):any(function(r) return not r.ok end)
  vim.cmd(failed and "cq!" or "qa!")
end, 3000)
