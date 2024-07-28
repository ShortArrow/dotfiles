local M = {}
M.lsp_sig_config = {
  bind = true, -- This is mandatory, otherwise border config won't get registered.
  handler_opts = {
    border = "rounded"
  }
}
local function get_project_root()
  local output = vim.fn.systemlist('git rev-parse --show-toplevel')
  if vim.v.shell_error ~= 0 or #output == 0 then
    return nil
  end

  return output[1]
end

M.setup = function()
  local _api = require('my')
  local _nvim_lsp = require('lspconfig')
  local _mason = require('mason')
  local _mason_lspconfig = require('mason-lspconfig')
  local _mason_nullls = require('mason-null-ls')
  local _lsp_sig = require('lsp_signature')
  local _cmp_nvim_lsp = require('cmp_nvim_lsp')
  local _mason_dap = require("mason-nvim-dap")
  require('dap')
  -- Define the sign for a breakpoint
  vim.fn.sign_define('DapBreakpoint', { text = ' ', texthl = 'ErrorMsg', linehl = '', numhl = '' })
  local capabilities = _cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
  }
  _mason.setup {
    ui = {
      icons = {
        package_installed = "✓ ",
        package_pending = "➜ ",
        package_uninstalled = "✗ "
      }
    }
  }
  _mason_lspconfig.setup()
  _mason_dap.setup({
    handlers = {
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
  })
  _mason_nullls.setup({
    ensure_installed = {
      -- Opt to list sources here, when available in mason.
    },
    automatic_installation = false,
    automatic_setup = true, -- Recommended, but optional
    handlers = {}
  })
  _mason_lspconfig.setup_handlers({
    function(server_name)
      local _opts = {}
      if server_name == "sumneko_lua" then
        _opts.settings = _api.lang.lua.sumneko_lua
      elseif server_name == "tsserver" then
        if not _api.lang.ts.has_package_json() then
          return
        else
          _opts.root_dir = get_project_root
          _opts.settings = _api.lang.ts.tsserver
        end
      elseif server_name == "eslint" then
        _opts.root_dir = get_project_root
      elseif server_name == "denols" then
        if not _api.lang.deno.has_deno_json() then
          return
        else
          _opts.root_dir = get_project_root
          _opts.settings = _api.lang.deno.denols
        end
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
      elseif server_name == "clangd" then
        _opts.settings = _api.lang.clang.clangd
      elseif server_name == "powershell_es" then
        _opts.settings = _api.lang.pwsh.powershell_es
      elseif server_name == "astro-ls" then
        _opts.settings = _api.lang.astro.astro_ls
      end
      _opts.capabilities = capabilities
      _opts.capabilities.offsetEncoding = { 'utf-16' } -- this is temporary patch https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
      _opts.on_attach = function(_, bufnr)
        _lsp_sig.on_attach(M.lsp_sig_config, bufnr)
      end
      _nvim_lsp[server_name].setup(_opts)
    end
  })
end

return M
