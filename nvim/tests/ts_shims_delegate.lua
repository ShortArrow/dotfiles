--- Given: the config shadows nvim-treesitter.parsers with a shim that
--- delegates to the plugin's own module.
--- When: a plugin requires the shim before nvim-treesitter is loaded
--- (vim-illuminate does at startup), and nvim-treesitter loads afterwards.
--- Then: the shim carries the plugin's content, so :TSInstall and :TSUpdate
--- see the declared languages — stdpath("data") ("nvim-data") shares a
--- string prefix with stdpath("config") ("nvim") and must not be excluded.
--- Run with: nvim --headless "+luafile <this file>"
vim.defer_fn(function()
  local results = {}
  local function check(ok, msg)
    table.insert(results, { ok = ok, msg = msg })
  end

  package.loaded["nvim-treesitter.parsers"] = nil
  local lazy_cfg = require("lazy.core.config")
  local rtp = vim.opt.rtp:get()
  vim.opt.rtp:remove(lazy_cfg.plugins["nvim-treesitter"].dir)
  local early = require("nvim-treesitter.parsers")
  vim.opt.rtp = rtp
  require("lazy").load({ plugins = { "nvim-treesitter" } })
  check(early == require("nvim-treesitter.parsers"), "early require is the cached module")
  local parsers = require("nvim-treesitter.parsers")
  check(parsers.lua ~= nil and parsers.lua.install_info ~= nil, "parsers shim delegates (lua is known)")
  check(type(parsers.has_parser) == "function", "parsers shim keeps has_parser")

  for _, r in ipairs(results) do
    print((r.ok and "OK: " or "FAIL: ") .. r.msg)
  end
  local failed = vim.iter(results):any(function(r) return not r.ok end)
  vim.cmd(failed and "cq!" or "qa!")
end, 1000)
