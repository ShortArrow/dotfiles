--- Given: a buffer whose language has a treesitter parser available.
--- When: the FileType autocmd decides whether to start treesitter highlight.
--- Then: the highlighter is active only if the highlights query compiles —
--- a parser older than the plugin's query otherwise floods every redraw
--- with decoration errors (e.g. bundled `vim` parser vs "substitute" node).
--- Run with: nvim --headless "+luafile <this file>"
vim.defer_fn(function()
  local results = {}
  local function check(ok, msg)
    table.insert(results, { ok = ok, msg = msg })
  end

  for _, case in ipairs({
    { file = vim.env.VIMRUNTIME .. "/filetype.lua", lang = "lua" },
    { file = vim.env.VIMRUNTIME .. "/syntax/vim.vim", lang = "vim" },
  }) do
    vim.cmd.edit(case.file)
    local buf = vim.api.nvim_get_current_buf()
    vim.wait(2000)
    local active = vim.treesitter.highlighter.active[buf] ~= nil
    local query_ok, query = pcall(vim.treesitter.query.get, case.lang, "highlights")
    local compiles = query_ok and query ~= nil
    if active and not compiles then
      check(false, case.lang .. ": highlighter active but highlights query does not compile")
    else
      check(true, ("%s: highlighter=%s, query compiles=%s"):format(
        case.lang, tostring(active), tostring(compiles)))
    end
  end

  local messages = vim.fn.execute("messages")
  check(not messages:match("Query error") and not messages:match("Invalid node type"),
    "no treesitter query errors in :messages")

  for _, r in ipairs(results) do
    print((r.ok and "OK: " or "FAIL: ") .. r.msg)
  end
  local failed = vim.iter(results):any(function(r) return not r.ok end)
  vim.cmd(failed and "cq!" or "qa!")
end, 1000)
