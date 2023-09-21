vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  update_in_insert = false,
  virtual_text = {
    format = function(diagnostic)
      return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
    end,
  },
})

-- severity levels of problems
-- By default, they are E for Error, W for Warning, H for Hints, I for Informations.
-- They are shown in the sign column on the left-most side
local signs = { Error = " ", Warn = " ", Hint = "󰅺 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- print error/warning/hints/information in the message area
-- when your cursor is on any line having them
function PrintDiagnostics(opts, bufnr, line_nr, _ --[[ client_id ]])
  bufnr = bufnr or 0
  line_nr = line_nr or (vim.api.nvim_win_get_cursor(0)[1] - 1)
  opts = opts or { ['lnum'] = line_nr }

  local line_diagnostics = vim.diagnostic.get(bufnr, opts)
  if vim.tbl_isempty(line_diagnostics) then return end

  local diagnostic_message = ""
  for i, diagnostic in ipairs(line_diagnostics) do
    diagnostic_message = diagnostic_message .. string.format("%d: %s", i, diagnostic.message or "")
    print(diagnostic_message)
    if i ~= #line_diagnostics then
      diagnostic_message = diagnostic_message .. "\n"
    end
  end
  vim.api.nvim_echo({ { diagnostic_message, "Normal" } }, false, {})
end

-- vim.cmd [[ autocmd! CursorHold * lua PrintDiagnostics() ]]

vim.diagnostic.config({
  virtual_text = {
    -- source = "always",  -- "always" Or "if_many"
    prefix = '●', -- Could be '■', '▎', 'x'
  },
  signs = true,
  update_in_insert = true,
  underline = true,
  severity_sort = true,
  float = {
    source = "if_many",     -- "always" Or "if_many"
    border = 'rounded',
    header = '',
    prefix = '',
  },
})

vim.cmd([[
set signcolumn=yes
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])
