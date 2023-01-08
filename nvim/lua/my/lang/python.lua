local M = {}

M.is_test_of_python = function(stuff)
  return nil ~= string.find(stuff, "test")
end
M.neotest = {
  -- Extra arguments for nvim-dap configuration
  -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
  dap = { justMyCode = false },
  -- Command line arguments for runner
  -- Can also be a function to return dynamic values
  args = { "--log-level", "DEBUG" },
  -- Runner to use. Will use pytest if available by default.
  -- Can be a function to return dynamic value.
  runner = "pytest",
  -- Custom python path for the runner.
  -- Can be a string or a list of strings.
  -- Can also be a function to return dynamic value.
  -- If not provided, the path will be inferred by checking for
  -- virtual envs in the local directory and for Pipenev/Poetry configs
  python = ".venv/bin/python",
  -- Returns if a given file path is a test file.
  -- NB: This function is called a lot so don't perform any heavy tasks within it.
  is_test_file = function(file_path)
    return M.is_test_of_python(file_path)
  end,
}
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
      rope_completion = { enabled = true }
    }
  }
}

M.env = function()
  local _env = require('my.env')
  -- python path https://imokuri123.com/blog/2017/07/neovim-python-virtualenv/
  vim.g.loaded_python_provider = 0
  if _env.is_win_os() then
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
