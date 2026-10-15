--- Given: kakehashi is configured through _mason_lspconfig.
--- When: a markdown buffer loads the LSP setup.
--- Then: autoInstall sits under languages._ (the top-level key is
--- deprecated and removed in kakehashi v2), and the markdown bridge stays.
--- Run with: nvim --headless "+luafile <this file>"
vim.defer_fn(function()
  local results = {}
  local function check(ok, msg)
    table.insert(results, { ok = ok, msg = msg })
  end

  local md = vim.fn.tempname() .. ".md"
  vim.fn.writefile({ "# probe" }, md)
  vim.cmd.edit(md)
  vim.wait(3000, function() return vim.g.__mason_lspconfig_setup_done == true end)

  local opts = (vim.lsp.config.kakehashi or {}).init_options or {}
  local languages = opts.languages or {}
  check(opts.autoInstall == nil, "no top-level autoInstall")
  check(vim.tbl_get(languages, "_", "autoInstall") == true, "languages._.autoInstall is true")
  check(type(vim.tbl_get(languages, "markdown", "bridge")) == "table", "markdown bridge kept")

  for _, r in ipairs(results) do
    print((r.ok and "OK: " or "FAIL: ") .. r.msg)
  end
  local failed = vim.iter(results):any(function(r) return not r.ok end)
  vim.cmd(failed and "cq!" or "qa!")
end, 1000)
