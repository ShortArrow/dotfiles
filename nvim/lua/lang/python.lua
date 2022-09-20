local api = require('my.api')
M = {}

M.pyright = {
  cmd = { "py" },
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        diagnosticMode = "workspace",
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
        },
      },
    },
  },
}

M.pyls = {
  cmd = {"pyls"},
  cmd_env = {VIRTUAL_ENV = "./.venv/"},
}

M.env = function()
  -- python path https://imokuri123.com/blog/2017/07/neovim-python-virtualenv/
  if api.env.is_win_os() then
    vim.g.python3_host_prog = './.venv/Script/python'
  else
    vim.g.python3_host_prog = './.venv/bin/python'
  end
end

return M
