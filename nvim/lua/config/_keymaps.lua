local depends = require('config._depends')

local M = {}

-- switchぽい関数分岐
M.setup = function(dep)
    local switchCase = {}
    switchCase[depends.fugitive] = M.KeyMapFugitive
    switchCase[depends.flutter] = M.KeyMapFugitive
    switchCase[dep]()
end

M.KeyMapFugitive = function()
  vim.api.nvim_set_keymap('n', '<Leader>gh',':Gstatus<CR>', { noremap = true })
  -- nnoremap <leader>ga :Git add %:p<CR><CR>
  -- nnoremap <leader>gc :Gcommit<CR><CR>
  -- nnoremap <leader>gs :Gstatus<CR>
  -- nnoremap <leader>gp :Gpush<CR>
  -- nnoremap <leader>gd :Gdiff<CR>
  -- nnoremap <leader>gl :Glog<CR>
  -- nnoremap <leader>gb :Gblame<CR>
end

return M
