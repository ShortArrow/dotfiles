local M = {}

local function as_set(list)
  local set = {}
  if type(list) == "string" then
    list = { list }
  end
  if type(list) == "table" then
    for _, v in ipairs(list) do
      set[v] = true
    end
  end
  return set
end

local function ensure_install(langs)
  if not langs or langs == "all" then return end
  if type(langs) == "table" and #langs == 0 then return end
  pcall(function()
    require("nvim-treesitter").install(langs)
  end)
end

function M.setup(opts)
  opts = opts or {}

  ensure_install(opts.ensure_installed)

  local highlight = opts.highlight or {}
  if highlight.enable then
    local disabled = as_set(highlight.disable or {})
    local group = vim.api.nvim_create_augroup("TSCompatHighlight", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if disabled[ft] then return end
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end
end

return M
