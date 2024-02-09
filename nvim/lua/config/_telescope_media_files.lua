local M = {}

M.setup = function()
  local _telescope = require('telescope')
  _telescope.setup {
    extensions = {
      media_files = {
        -- filetypes whitelist
        -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
        filetypes = { "png", "webp", "jpg", "jpeg" },
        -- find command (defaults to `fd`)
        find_cmd = "rg"
      }
    }
  }
  _telescope.load_extension('media_files')
end

return M
