local M = {}

M.setup = function()
  local _mason_nullls = require('mason-null-ls')
  local mason_dap = require("mason-nvim-dap")
  mason_dap.setup({
    handlers = {
      function(config)
        -- all sources with no handler get passed here
        -- Keep original functionality of `automatic_setup = true`
        require('mason-nvim-dap.automatic_setup')(config)
      end,
      -- coreclr = function(config)
      --   _dap.adapters.coreclr = _api.lang.csharp.nullls_config
      --   -- _dap.adapters.cs = _api.lang.csharp.nullls_config
      --   _dap.configurations.cs = _api.lang.csharp.dap_config
      -- end,
      python = function(config)
        _mason_nullls.adapters.python = _api.lang.python.nullls_config
        _mason_dap.configurations.python = _api.lang.python.dap_config
      end,
    }
  })
end

return M
