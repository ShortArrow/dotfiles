local M = {}
M.lsp_sig_config = {
  bind = true, -- This is mandatory, otherwise border config won't get registered.
  handler_opts = {
    border = "rounded"
  }
}
M.setup = function()
  local _api = require('my')
  local _nvim_lsp = require('lspconfig')
  local _mason = require('mason')
  local _mason_lspconfig = require('mason-lspconfig')
  local _mason_nullls = require('mason-null-ls')
  local _lsp_sig = require('lsp_signature')
  local _cmp_nvim_lsp = require('cmp_nvim_lsp')
  local _mason_dap = require("mason-nvim-dap")
  local capabilities = _cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
  }
  _mason.setup {
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
      }
    }
  }
  _mason_lspconfig.setup()
  _mason_dap.setup({
    automatic_setup = true,
  })
  _mason_dap.setup_handlers {
    function(source_name)
      -- all sources with no handler get passed here


      -- Keep original functionality of `automatic_setup = true`
      require('mason-nvim-dap.automatic_setup')(source_name)
    end,
    python = function(source_name)
      _mason_nullls.adapters.python = {
        type = "executable",
        command = "/usr/bin/python3",
        args = {
          "-m",
          "debugpy.adapter",
        },
      }

      _mason_dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}", -- This configuration will launch the current file if used.
        },
      }
    end,
  }
  _mason_nullls.setup({
    ensure_installed = {
      -- Opt to list sources here, when available in mason.
    },
    automatic_installation = false,
    automatic_setup = true, -- Recommended, but optional
  })
  _mason_nullls.setup_handlers() -- If `automatic_setup` is true.
  _mason_lspconfig.setup_handlers({
    function(server_name)
      local packagejson_finder = _nvim_lsp.util.root_pattern("package.json")
      local is_nodejs = function()
        return nil ~= packagejson_finder(vim.api.nvim_buf_get_name(0))
      end
      local _opts = {}
      if server_name == "sumneko_lua" then
        _opts.settings = _api.lang.lua.sumneko_lua
      elseif server_name == "tsserver" then
        print("ts", is_nodejs(), vim.api.nvim_buf_get_name(0))
        if not is_nodejs() then return end
        _opts.root_dir = _nvim_lsp.util.root_pattern("package.json")
        _opts.settings = _api.lang.ts.tsserver
      elseif server_name == "eslint" then
        print("es", is_nodejs(), vim.api.nvim_buf_get_name(0))
        if not is_nodejs() then return end
        _opts.root_dir = _nvim_lsp.util.root_pattern("package.json")
      elseif server_name == "denols" then
        print("ds", not is_nodejs(), vim.api.nvim_buf_get_name(0))
        if is_nodejs() then return end
        _opts.root_dir = _nvim_lsp.util.root_pattern("deno.json")
        _opts.settings = _api.lang.deno.denols
        -- _opts.init_options = {
        --   lint = true,
        --   unstable = true,
        --   suggest = {
        --     imports = {
        --       hosts = {
        --         ["https://deno.land"] = true,
        --         ["https://cdn.nest.land"] = true,
        --         ["https://crux.land"] = true
        --       }
        --     }
        --   }
        -- }
      elseif server_name == "intelephense" then
        _opts.settings = _api.lang.php.intelephense
      elseif server_name == "pyright" then
        _opts.settings = _api.lang.python.pyright
      elseif server_name == "pyls" then
        _opts.settings = _api.lang.python.pylsp
      elseif server_name == "powershell_es" then
        _opts.settings = _api.lang.pwsh.powershell_es
      end
      _opts.capabilities = capabilities
      _opts.on_attach = function(_, bufnr)
        _lsp_sig.on_attach(M.lsp_sig_config, bufnr)
      end
      _nvim_lsp[server_name].setup(_opts)
    end
  })
end

return M
