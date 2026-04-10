local M = {}

--- Extract the markdown link under the cursor
--- @return { type: "file", path: string } | { type: "url", url: string } | nil
local function get_link_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1

  for link_start, target, link_end in line:gmatch("()%[.-%]%((.-)()%)") do
    if col >= link_start and col < link_end then
      if target:match("^https?://") then
        return { type = "url", url = target }
      else
        return { type = "file", path = target }
      end
    end
  end
  return nil
end

local function preview_file(path)
  local buf_dir = vim.fn.expand("%:p:h")
  local full_path = vim.fn.resolve(buf_dir .. "/" .. path)

  if vim.fn.filereadable(full_path) == 0 then
    vim.notify("File not found: " .. full_path, vim.log.levels.WARN)
    return
  end

  local lines = vim.fn.readfile(full_path)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"

  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 6)
  vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = path,
  })
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, nowait = true })
end

M.hover_or_preview = function()
  local link = get_link_under_cursor()
  if link and link.type == "file" then
    preview_file(link.path)
  else
    vim.cmd("Lspsaga hover_doc")
  end
end

local function resolve_path(path)
  local buf_dir = vim.fn.expand("%:p:h")
  return vim.fn.resolve(buf_dir .. "/" .. path)
end

M.goto_definition = function()
  local link = get_link_under_cursor()
  if link then
    if link.type == "file" then
      vim.cmd("normal! m'")
      vim.cmd("edit " .. vim.fn.fnameescape(resolve_path(link.path)))
    elseif link.type == "url" then
      vim.ui.open(link.url)
    end
  else
    vim.cmd("Lspsaga goto_definition")
  end
end

return M
