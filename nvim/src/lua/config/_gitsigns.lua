local M = {}

M.setup = function()
  require('gitsigns').setup({
    attach_to_untracked = false,
    diff_opts = {
      internal = true,
      -- Ignore CRLF/LF-only differences while keeping other whitespace diffs
      ignore_whitespace_change_at_eol = true,
    },
    signcolumn = true,
    numhl      = true,
  })
end

return M
