local M = {}

M.is_function = function(stuff)
  return type(stuff) == 'function'
end

M.is_boolean = function(stuff)
  return type(stuff) == 'boolean'
end

---Converts to zenkaku katakana from hankaku katakana
---@return nil
M.convert_to_zenkaku = function()
  local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, '<'), 0, 4)
  local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, '>'), 0, 4)
  if not M.is_selection_hankaku_katakana(start_line, start_col, end_line, end_col) then
    print("Selected text is not hankaku katakana")
    return
  end
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  local zenkaku_lines = {}
  for i, line in ipairs(lines) do
    local zenkaku_line = M.convert_hankaku_to_zenkaku(line)
    table.insert(zenkaku_lines, zenkaku_line)
  end
  vim.api.nvim_buf_set_lines(0, start_line, start_line + #zenkaku_lines, false, zenkaku_lines)
end

---Converts hankaku katakana to zenkaku katakana
---@param hankaku string
M.convert_hankaku_to_zenkaku = function(hankaku)
  local zenkaku = ""
  local i = 1
  while i <= #hankaku do
    local c = hankaku:sub(i, i)
    if c == 'ﾞ' then
      zenkaku = zenkaku:sub(1, -2) .. string.char(zenkaku:byte(-1) + 1)
    elseif c == 'ﾟ' then
      zenkaku = zenkaku:sub(1, -2) .. string.char(zenkaku:byte(-1) + 2)
    else
      zenkaku = zenkaku .. string.char(c:byte() + 0x60)
    end
    i = i + 1
  end
  return zenkaku
end

M.is_selection_hankaku_katakana = function(start_line, start_col, end_line, end_col)
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  if #lines == 0 then
    return false -- if no lines are selected
  end
  for i, line in ipairs(lines) do
    local selected_text
    if i == 1 and i == #lines then -- selection is in one line
      selected_text = line:sub(start_col + 1, end_col)
    elseif i == 1 then             -- at the first line of selection
      selected_text = line:sub(start_col + 1)
    elseif i == #lines then        -- at the last line of selection
      selected_text = line:sub(1, end_col)
    else                           -- at the middle of selection
      selected_text = line
    end
    if not selected_text:match('^[ｦ-ﾟ]+$') then
      return false -- if not all characters are hankaku katakana
    end
  end
  return true
end

vim.keymap.set(
  'v',
  '<Leader>fk'           ,
  function() M.convert_to_zenkaku() end,
  { noremap = true, silent = true }
)

return M
