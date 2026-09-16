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

local GITHUB_URL_HEAD = "https?://github%.com/"

--- Rewrite every bare or <autolinked> GitHub repository URL on one line as
--- [owner/repo](url). A URL already inside a markdown link is left alone,
--- and so is a URL that names an owner without a repository.
--- @param line string
--- @return string
M.linkify_line = function(line)
  local out, pos = {}, 1
  while true do
    local s, e = line:find(GITHUB_URL_HEAD, pos)
    if not s then break end
    local ue = e
    while ue < #line and not line:sub(ue + 1, ue + 1):match("[%s<>%]%)\"']") do
      ue = ue + 1
    end
    while ue > e and line:sub(ue, ue):match("[.,;:!?]") do
      ue = ue - 1
    end
    local url = line:sub(s, ue)
    local owner, repo = url:match("^https?://github%.com/([%w%-%._]+)/([%w%-%._]+)")
    local before = line:sub(1, s - 1)
    local inside_link = before:sub(-1) == "[" or before:sub(-2) == "]("
    local autolink = before:sub(-1) == "<" and line:sub(ue + 1, ue + 1) == ">"
    if owner and repo and not inside_link then
      local rs, re = s, ue
      if autolink then rs, re = s - 1, ue + 1 end
      table.insert(out, line:sub(pos, rs - 1))
      table.insert(out, ("[%s/%s](%s)"):format(owner, repo, url))
      pos = re + 1
    else
      table.insert(out, line:sub(pos, ue))
      pos = ue + 1
    end
  end
  table.insert(out, line:sub(pos))
  return table.concat(out)
end

--- Apply linkify_line to a line range of the current buffer, whole buffer
--- when no range is given. Lines are 1-based and inclusive.
--- @param first integer|nil
--- @param last integer|nil
M.linkify_github_urls = function(first, last)
  first = first or 1
  last = last or vim.api.nvim_buf_line_count(0)
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  local changed = 0
  for i, l in ipairs(lines) do
    local n = M.linkify_line(l)
    if n ~= l then
      lines[i] = n
      changed = changed + 1
    end
  end
  if changed > 0 then
    vim.api.nvim_buf_set_lines(0, first - 1, last, false, lines)
  end
  vim.notify(("GitHub URLs linkified on %d line(s)"):format(changed))
end

return M
