local _cmp = require('_cmp')

local M = {}

M.setup = function()
  -- Setup lspconfig.
  local capabilities = _cmp.cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  require('lspconfig')['bashls'].setup{}
  require('lspconfig')['yamlls'].setup {
    capabilities = capabilities,
    on_attach = _cmp.lsp_sig.on_attach
  }
  require('lspconfig')['marksman'].setup {
    capabilities = capabilities
    -- ltex (latex)
    -- marksman (markdown)
    -- prosemd_lsp (markdown)
    -- remark_ls (markdown)
    -- zk (markdown)
  }
  require('lspconfig')['dartls'].setup {
    capabilities = capabilities
  }
  require('lspconfig')['rust_analyzer'].setup {
    capabilities = capabilities,
    on_attach = _cmp.lsp_sig.on_attach
  }
  require('lspconfig')['dockerls'].setup {
    capabilities = capabilities
  }
  require('lspconfig')['sumneko_lua'].setup {
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
    on_attach = _cmp.lsp_sig.on_attach
  }
end

return M
