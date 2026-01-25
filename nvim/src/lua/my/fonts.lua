local M = {}

M.concatinate_fontnames = function(list)
  local line
  for key, value in pairs(list) do
    if string.find(value, ' ') then
      value = '\'' .. value .. '\''
    end
    if key == 1 then
      line = value
    else
      line = line .. ',' .. value
    end
  end
  return line
end

M.get_fonts = function()
  local list = {
    'PlemolJPConsoleNF',
    'BlexMono Nerd Font',
    'RbotoJ',
    'cascadia code',
    'Fira Code',
    'Source Code Pro',
    'Consolas',
    'Courier New',
    'monospace',
  }
  return M.concatinate_fontnames(list)
end

M.set_font_width = function()
  local cellwidths = vim.fn.getcellwidths()

  -- Unicode Standard Miscellaneous Symbols
  table.insert(cellwidths, { 0x2600, 0x26ff, 1 })

  -- Seti-UI + Custom
  table.insert(cellwidths, { 0xe5fa, 0xe6ac, 1 })

  -- Devicons
  table.insert(cellwidths, { 0xe700, 0xe7c5, 1 })

  -- Font Awesome
  table.insert(cellwidths, { 0xf000, 0xf2e0, 1 })

  -- Font Awesome Extension
  table.insert(cellwidths, { 0xe200, 0xe2a9, 1 })

  -- Material Design Icons
  table.insert(cellwidths, { 0xf0001, 0xf1af0, 1 })

  -- Weather
  table.insert(cellwidths, { 0xe300, 0xe3e3, 1 })

  -- Octicons
  table.insert(cellwidths, { 0xf400, 0xf532, 1 })

  -- Powerline Symbols
  table.insert(cellwidths, { 0xe0a0, 0xe0a2, 1 })
  table.insert(cellwidths, { 0xe0b0, 0xe0b3, 1 })

  -- Powerline Extra Symbols
  table.insert(cellwidths, { 0xe0a3, 0xe0a3, 1 })
  table.insert(cellwidths, { 0xe0b4, 0xe0c8, 1 })
  table.insert(cellwidths, { 0xe0ca, 0xe0ca, 1 })
  table.insert(cellwidths, { 0xe0cc, 0xe0d4, 1 })

  -- IEC Power Symbols
  table.insert(cellwidths, { 0x23fb, 0x23fe, 1 })
  table.insert(cellwidths, { 0x2b58, 0x2b58, 1 })

  -- Font Logos
  table.insert(cellwidths, { 0xf300, 0xf32f, 1 })

  -- Pomicons
  table.insert(cellwidths, { 0xe000, 0xe00a, 1 })

  -- Codicons
  table.insert(cellwidths, { 0xea60, 0xebeb, 1 })

  -- Heavy Angle Brackets
  table.insert(cellwidths, { 0x276c, 0x2771, 1 })

  -- Box Drawing
  table.insert(cellwidths, { 0x2500, 0x259f, 1 })

  vim.fn.setcellwidths(cellwidths)
end

return M
