local M = {}

M.setup = function()
  -- require('fuzzy').setup {
  --   width = 60,
  --   height = 40,
  --   blacklist = {
  --     "vendor"
  --   },
  --   border = 'yes', -- can be 'no' as well
  --   --location = loc.bottom_center,
  --   sorter = require'fuzzy.lib.sorter'.fzy, -- Also fzf_native, fzy_native, string_distance are supported
  --   prompt = '> ',
  --   register = {
  --     some_custom_function = function() -- This function appears in complete menu when using :Fuzzy command.
  --     end
  --   },
  -- }
end

return M
