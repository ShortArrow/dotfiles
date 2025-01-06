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
    },
    defaults = {
      -- configure to use ripgrep
      vimgrep_arguments = {
        "rg",
        "--follow",      -- Follow symbolic links
        "--hidden",      -- Search for hidden files
        "--no-heading",  -- Don't group matches by each file
        "--with-filename", -- Print the file path with the matched lines
        "--line-number", -- Show line numbers
        "--column",      -- Show column numbers
        "--smart-case",  -- Smart case search

        -- Exclude some patterns from search
        "--glob=!**/.git/*",
        "--glob=!**/.idea/*",
        "--glob=!**/.vscode/*",
        "--glob=!**/build/*",
        "--glob=!**/dist/*",
        "--glob=!**/yarn.lock",
        "--glob=!**/package-lock.json",
      },
    },
    pickers = {
      find_files = {
        hidden = true,
        -- needed to exclude some files & dirs from general search
        -- when not included or specified in .gitignore
        find_command = {
          "rg",
          "--files",
          "--hidden",
          "--glob=!**/.git/*",
          "--glob=!**/.idea/*",
          "--glob=!**/.vscode/*",
          "--glob=!**/build/*",
          "--glob=!**/dist/*",
          "--glob=!**/yarn.lock",
          "--glob=!**/package-lock.json",
        },
      },
    },
  }
  _telescope.load_extension('media_files')
end

return M
