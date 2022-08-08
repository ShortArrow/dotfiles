local _cmp_nvim_lsp = require('cmp_nvim_lsp')
local __lsp_sig = require('config._lsp_sig')
local _lsp_config = require('lspconfig')

local M = {}

M.setup = function()
  -- Setup lspconfig.
  local capabilities = _cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  _lsp_config['bashls'].setup{}
  _lsp_config['yamlls'].setup {
    capabilities = capabilities,
    on_attach = __lsp_sig.on_attach
  }
  _lsp_config['marksman'].setup {
    capabilities = capabilities
    -- ltex (latex)
    -- marksman (markdown)
    -- prosemd_lsp (markdown)
    -- remark_ls (markdown)
    -- zk (markdown)
  }
  _lsp_config['dartls'].setup {
    capabilities = capabilities
  }
  _lsp_config['rust_analyzer'].setup {
    capabilities = capabilities,
    on_attach = __lsp_sig.on_attach
  }
  _lsp_config['dockerls'].setup {
    capabilities = capabilities
  }
  _lsp_config['sumneko_lua'].setup {
    capabilities = capabilities,
    settings = {
      Lua = {
        workspace = {
          library = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
            [vim.fn.expand('/usr/share/awesome/lib')] = true
          },
          -- adjust these two values if your performance is not optimal
          maxPreload = 2000,
          preloadFileSize = 1000
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = {'vim'},
        },
        format = {
          enable = true,
          defaultConfig = {
            indent_style = "space",
            indent_size = "2",
          },
        },
      },
    },
    on_attach = __lsp_sig.on_attach
  }
end

return M
