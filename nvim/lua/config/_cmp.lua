local M = {}

M.setup = function()
  vim.o.completeopt = 'menu,menuone,noselect'
  -- Setup nvim-cmp.
  local cmp_nvim_lsp = require('cmp_nvim_lsp')
  local lsp_sig = require('config._lsp_sig')
  local lspkind = require('lspkind')
  local cmp = require('cmp')
  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    -- window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    -- },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = true  -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      }),
      ['<Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
      ['<S-Tab>'] = function(fallback)
        if cmp.visivle() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    }),
    formatting = {
      format = lspkind.cmp_format({
        mode = 'symbol', -- show only symbol annotations
        maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
        -- The function below will be called before any actual modifications from lspkind
        -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
        before = function (entry, vim_item)
          return vim_item
        end
      })
    }
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Setup lspconfig.
  local capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  require('lspconfig')['yamlls'].setup {
    capabilities = capabilities,
    on_attach = lsp_sig.on_attach
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
    on_attach = lsp_sig.on_attach
  }
  require('lspconfig')['dockerls'].setup {
    capabilities = capabilities
  }
--  local sumneko_root_path = os.getenv("HOME") ..
--                              "/Documents/GitHub/lua-language-server/bin"
 -- local sumneko_binary = sumneko_root_path .. "/bin/Linux/lua-language-server"
  require('lspconfig')['sumneko_lua'].setup {
  --  cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
    capabilities = capabilities,
  --  vim.o.LanguageClient_serverCommands = {
  	  -- 'lua': ['lua-lsp'],
  	-- }
    -- vim.o.LanguageClient_autoStart = 1
    settings = {
      Lua = {
   --     runtime = {version = 'LuaJIT', path = vim.split(package.path, ';')},
    --        completion = {enable = true, callSnippet = "Both"},
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
    on_attach = lsp_sig.on_attach
  }
end

return M
