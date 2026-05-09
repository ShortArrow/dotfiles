local M = {}

M.setup = function()
  require("flash").setup({
    -- Defaults are sensible; keep config minimal so upstream changes
    -- propagate without local overrides going stale.
    modes = {
      -- Disable enhanced f/F/t/T to preserve native single-char repeat.
      char = { enabled = false },
      -- Enable label hints during '/' / '?' search.
      search = { enabled = true },
    },
  })
end

return M
