local ok, mod = pcall(require, "vim.treesitter.query")
local query = ok and mod or vim.treesitter.query

if query and not query.has_locals then
  query.has_locals = function(lang)
    if not lang or lang == "" then return false end
    local ok_get, q = pcall(query.get, lang, "locals")
    return ok_get and q ~= nil
  end
end

return query
