local api = require('my.api')
M = {}

M.pyright = {
  cmd = { "python" },
  settings = {
    python = {
      venvPath = "./venv/",
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

M.pylsp = {
  pyls = {
    plugins = {
      jedi_completion = { enabled = true },
      jedi_hover = { enabled = true },
      jedi_references = { enabled = true },
      jedi_signature_help = { enabled = true },
      jedi_symbols = { enabled = true, all_scopes = true },
      pycodestyle = { enabled = false },
      mypy = { enabled = false },
      isort = { enabled = false },
      yapf = { enabled = false },
      pylint = { enabled = false },
      pydocstyle = { enabled = true },
      mccabe = { enabled = false },
      preload = { enabled = false },
      rope_completion = { enabled = true}
    }
  }
}

M.env = function()
  -- python path https://imokuri123.com/blog/2017/07/neovim-python-virtualenv/
  vim.g.loaded_python_provider = 0
  if api.env.is_win_os() then
    vim.g.python_dir = ".\\.venv\\Scripts\\"
    vim.g.python3_dir = ".\\.venv\\Scripts\\"
    vim.g.python_host_prog = vim.g.python_dir .. 'python.exe'
    vim.g.python3_host_prog = vim.g.python3_dir .. 'python.exe'
  else
    vim.g.python_dir = './.venv/bin/'
    vim.g.python3_dir = './.venv/bin/'
    vim.g.python_host_prog = vim.g.python_dir .. 'python'
    vim.g.python3_host_prog = vim.g.python3_dir .. 'python'
  end
end

return M
