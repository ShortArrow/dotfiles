-- rustowl helper module.
--
-- Provides:
--   * M.toggle / M.yank        — floating status window (bound to <Leader>rs/ry)
--   * M.kick_when_ready        — wait for analysis to finish, then force one
--                                highlight pass at the current cursor position
--   * M.install_autohighlight  — install a BufWritePost hook that calls
--                                kick_when_ready automatically
--   * :RustowlStatus / :RustowlStatusYank user commands
--
-- Rationale: rustowl on its own only redraws on CursorMoved and only starts
-- a new analysis on textDocument/didSave (v0.3.4). That leaves two UX gaps:
-- the first post-save render is invisible until the user nudges the cursor,
-- and there is no indication that analysis is in progress. This module
-- bridges both with a small poller and an optional status float.

local M = {}

---@type integer? buffer id of the floating status buffer
local buf
---@type integer? window id of the floating status window
local win
---@type uv_timer_t? libuv timer driving the refresh loop
local timer
---@type boolean have we already notified on analysis completion
local notified_done = false
---@type integer refresh interval in ms
local INTERVAL_MS = 1000

local function is_open()
  return win ~= nil and vim.api.nvim_win_is_valid(win)
end

local function stop_timer()
  if timer then
    timer:stop()
    if not timer:is_closing() then timer:close() end
    timer = nil
  end
end

local function close_window()
  stop_timer()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
  win = nil
  buf = nil
  notified_done = false
end

---@param lines string[]
local function set_lines(lines)
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then return end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

---@return vim.lsp.Client?
local function get_client()
  local ok, lsp = pcall(require, "rustowl.lsp")
  if not ok then return nil end
  local clients = lsp.get_rustowl_clients({ bufnr = 0 })
  return clients[1]
end

local function refresh()
  if not is_open() then
    stop_timer()
    return
  end

  local header = {
    "RustOwl Status",
    "──────────────",
  }

  if vim.bo.filetype ~= "rust" then
    set_lines(vim.list_extend(header, {
      "(not a rust buffer)",
      "",
      "press <Leader>rs to close",
    }))
    return
  end

  local client = get_client()
  if not client then
    set_lines(vim.list_extend(header, {
      "LSP client:  not attached",
      "",
      "Open a file inside a Cargo",
      "project to attach rustowl.",
      "",
      "press <Leader>rs to close",
    }))
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local params = {
    position = { line = line - 1, character = col },
    document = vim.lsp.util.make_text_document_params(),
  }

  client:request("rustowl/cursor", params, function(err, result)
    if not is_open() then return end
    local lines = vim.deepcopy(header)
    table.insert(lines, ("LSP client:  id=%d"):format(client.id))
    if err then
      table.insert(lines, "request err: " .. tostring(err.message or err))
      set_lines(lines)
      return
    end
    if not result then
      table.insert(lines, "result:      nil")
      set_lines(lines)
      return
    end
    local analyzed = result.is_analyzed and "yes" or "no"
    local status = tostring(result.status or "?")
    local decos = result.decorations and #result.decorations or 0
    local path = tostring(result.path or "?")
    table.insert(lines, "is_analyzed: " .. analyzed)
    table.insert(lines, "status:      " .. status)
    table.insert(lines, "decorations: " .. tostring(decos))
    table.insert(lines, "")
    table.insert(lines, "path:")
    table.insert(lines, "  " .. path)
    table.insert(lines, "")
    table.insert(lines, "press <Leader>rs to close")
    set_lines(lines)

    if result.is_analyzed and not notified_done then
      notified_done = true
      vim.notify("rustowl: analysis finished", vim.log.levels.INFO)
    end
  end, bufnr)
end

local function open_window()
  local width = 34
  local height = 11

  local new_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[new_buf].bufhidden = "wipe"
  vim.bo[new_buf].filetype = "rustowlstatus"

  -- Use anchor = "NW" with explicit computed position. `noautocmd` is
  -- intentionally omitted here because it is not a valid field in
  -- nvim_open_win's config in some versions.
  local row = math.max(0, vim.o.lines - height - 4)
  local col = math.max(0, vim.o.columns - width - 2)

  local ok, new_win = pcall(vim.api.nvim_open_win, new_buf, false, {
    relative = "editor",
    anchor = "NW",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    focusable = false,
  })
  if not ok then
    vim.notify("rustowl_status: nvim_open_win failed: " .. tostring(new_win), vim.log.levels.ERROR)
    if vim.api.nvim_buf_is_valid(new_buf) then
      vim.api.nvim_buf_delete(new_buf, { force = true })
    end
    return
  end

  buf = new_buf
  win = new_win
  pcall(function() vim.wo[win].winblend = 10 end)

  set_lines({ "RustOwl Status", "──────────────", "(waiting...)" })

  -- Auto-close when the user leaves Neovim or on explicit close.
  vim.api.nvim_create_autocmd("VimLeavePre", {
    once = true,
    callback = function() close_window() end,
  })

  local t, err = vim.uv.new_timer()
  assert(t, err)
  timer = t
  timer:start(
    0,
    INTERVAL_MS,
    vim.schedule_wrap(function()
      if not is_open() then
        stop_timer()
        return
      end
      refresh()
    end)
  )
end

--- Toggle the rustowl status floating window.
function M.toggle()
  local ok, err = pcall(function()
    if is_open() then
      close_window()
    else
      open_window()
    end
  end)
  if not ok then
    vim.notify("rustowl_status.toggle error: " .. tostring(err), vim.log.levels.ERROR)
  end
end

---Wait for rustowl to finish analysis on the given buffer and force one
---highlight pass at the current cursor location. Without this the user
---has to nudge the cursor after analysis completes, because rustowl
---only requeries on CursorMoved and the first auto-fired request at
---save time returns an empty result while `status = "analyzing"`.
---
---Called from both the BufWritePost hook installed by
---install_autohighlight and the `<Leader>re` key binding that fakes a
---textDocument/didSave to kick analysis without a real buffer write.
---@param bufnr integer
function M.kick_when_ready(bufnr)
  local lsp_ok, lsp = pcall(require, "rustowl.lsp")
  if not lsp_ok then return end
  local clients = lsp.get_rustowl_clients({ bufnr = bufnr })
  local client = clients[1]
  if not client then return end

  local attempts = 0
  local max_attempts = 240 -- ~120 s at 500 ms cadence
  local t, err = vim.uv.new_timer()
  assert(t, err)
  local poll_timer = t

  local function stop()
    if poll_timer and not poll_timer:is_closing() then
      poll_timer:stop()
      poll_timer:close()
    end
  end

  poll_timer:start(500, 500, vim.schedule_wrap(function()
    attempts = attempts + 1
    if attempts > max_attempts then
      stop()
      return
    end
    if not vim.api.nvim_buf_is_valid(bufnr) then
      stop()
      return
    end
    local rustowl_ok, rustowl = pcall(require, "rustowl")
    if not rustowl_ok or not rustowl.is_enabled or not rustowl.is_enabled() then
      stop()
      return
    end
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_buf(win) ~= bufnr then
      return
    end
    local line, col = unpack(vim.api.nvim_win_get_cursor(win))
    local params = {
      position = { line = line - 1, character = col },
      document = vim.lsp.util.make_text_document_params(),
    }
    client:request("rustowl/cursor", params, function(_, result)
      if not result or not result.is_analyzed then return end
      stop()
      local hl_ok, hl = pcall(require, "rustowl.highlight")
      if not hl_ok then return end
      local line2, col2 = unpack(vim.api.nvim_win_get_cursor(win))
      pcall(hl.enable, line2, col2, bufnr)
    end, bufnr)
  end))
end

---Install a BufWritePost hook on the given buffer that waits for rustowl
---to finish analysis and then forces one highlight pass.
---Idempotent per buffer — calling twice is harmless.
---@param bufnr integer
function M.install_autohighlight(bufnr)
  local group = vim.api.nvim_create_augroup("RustowlAutoHighlight" .. bufnr, { clear = true })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    buffer = bufnr,
    desc = "rustowl: kick highlight once analysis finishes",
    callback = function() M.kick_when_ready(bufnr) end,
  })

  -- Also kick once right after install, so opening a buffer that was
  -- already analyzed (e.g. second visit) picks up highlights without
  -- requiring a save.
  M.kick_when_ready(bufnr)
end

--- Copy the status buffer contents to the + register (system clipboard).
--- Useful because the floating window is non-focusable.
function M.yank()
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    vim.notify("rustowl_status: window is not open", vim.log.levels.WARN)
    return
  end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local text = table.concat(lines, "\n")
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)
  vim.notify("rustowl_status: copied " .. #lines .. " lines to clipboard")
end

-- User commands, available globally so you can invoke them even when
-- on_attach's buffer-local keymaps are not registered yet (useful while
-- debugging the plugin integration itself).
vim.api.nvim_create_user_command("RustowlStatus", function() M.toggle() end, {
  desc = "Toggle rustowl status floating window",
})
vim.api.nvim_create_user_command("RustowlStatusYank", function() M.yank() end, {
  desc = "Yank rustowl status window contents to + register",
})

return M
