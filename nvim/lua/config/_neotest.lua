local api = require('my')
local M = {}

M.setup = function()
  require("neotest").setup({
    icons = {
      child_indent = "│ ",
      child_prefix = "├ ",
      collapsed = "─ ",
      expanded = "╮ ",
      failed = "x ",
      final_child_indent = " ",
      final_child_prefix = "╰ ",
      non_collapsible = "─ ",
      passed = " ",
      running = "勒 ",
      running_animated = { "/", "|", "\\", "-", "/", "|", "\\", "-" },
      skipped = "↩️ ",
      unknown = "?"
    },
    adapters = {
      require("neotest-python")(api.lang.python.neotest),
      require("neotest-plenary"),
      require("neotest-vitest"),
      require('neotest-jest')({
        jestCommand = "npm test --",
        jestConfigFile = "custom.jest.config.ts",
        env = { CI = true },
        cwd = function(path)
          return vim.fn.getcwd()
        end,
      }),
      require("neotest-rust")(api.lang.rust.neotest),
      require('neotest-dart') {
        command = 'flutter', -- Command being used to run tests. Defaults to `flutter`
        -- Change it to `fvm flutter` if using FVM
        -- change it to `dart` for Dart only tests
        use_lsp = true -- When set Flutter outline information is used when constructing test name.
      },
      require("neotest-vim-test")({
        ignore_file_types = { "python", "vim", "lua" },
      }),
    },
  })
end

return M
-- | pytest          |   [neotest-python](https://github.com/nvim-neotest/neotest-python)   |
-- | python-unittest |   [neotest-python](https://github.com/nvim-neotest/neotest-python)   |
-- | plenary         |  [neotest-plenary](https://github.com/nvim-neotest/neotest-plenary)  |
-- | go              |         [neotest-go](https://github.com/akinsho/neotest-go)          |
-- | jest            |     [neotest-jest](https://github.com/haydenmeade/neotest-jest)      |
-- | vitest          |     [neotest-vitest](https://github.com/marilari88/neotest-vitest)   |
-- | rspec           |     [neotest-rspec](https://github.com/olimorris/neotest-rspec)      |
-- | dart, flutter   |       [neotest-dart](https://github.com/sidlatau/neotest-dart)       |
-- | testthat        | [neotest-testthat](https://github.com/shunsambongi/neotest-testthat) |
-- | phpunit         |   [neotest-phpunit](https://github.com/olimorris/neotest-phpunit)    |
-- | rust            |        [neotest-rust](https://github.com/rouge8/neotest-rust)        |
-- | elixir          |    [neotest-elixir](https://github.com/jfpedroza/neotest-elixir)     |
-- | dotnet          |    [neotest-dotnet](https://github.com/Issafalcon/neotest-dotnet)    |
-- | scala           |    [neotest-scala](https://github.com/stevanmilic/neotest-scala)     |
-- | haskell         |    [neotest-haskell](https://github.com/mrcjkb/neotest-haskell)      |
