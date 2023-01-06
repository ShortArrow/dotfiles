local api = require('my')
local debugger = api.debugger

local M = {}

M.setup = function()
  vim.o.completeopt = 'menu,menuone,noselect'
  -- Setup nvim-cmp.
  local lspkind_ok, lspkind = pcall(require, 'lspkind')
  local luasnip_ok, luasnip = pcall(require, "luasnip")
  if not luasnip_ok then return end
  local compare = require('cmp.config.compare')
  local source_mapping = {
    buffer = "[Buffer]",
    nvim_lsp = "[LSP]",
    nvim_lua = "[Lua]",
    treesitter = "[🌳TS]",
    plugins = "[Plugins]",
    vsnip = "[VSnip]",
    path = "[Path]",
  }
  local cmp = require('cmp')
  if cmp ~= nil then
    cmp.setup({
      sorting = {
        priority_weight = 2,
        comparators = {
          compare.offset,
          compare.exact,
          compare.score,
          compare.recently_used,
          compare.kind,
          compare.sort_text,
          compare.length,
          compare.order,
        },
      },
      snippet = {
        expand = function(args) luasnip.lsp_expand(args.body) end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ["<Up>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
        ["<Down>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
        ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
        ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
        ["<C-k>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
        ["<C-j>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        ["<C-y>"] = cmp.config.disable,
        ["<C-e>"] = cmp.mapping {
          i = cmp.mapping.abort(),
          c = cmp.mapping.close(),
        },
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<CR>'] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        ['<Tab>'] = cmp.mapping(
          function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end,
          { "i", "s" }
        ),
        ['<S-Tab>'] = cmp.mapping(
          function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end,
          { "i", "s" }
        ),
      }),
      sources = cmp.config.sources({
        { name = 'calc' },
        { name = 'emoji' },
        { name = 'nerdfont' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lsp_signature_help' },
        { name = 'nvim_lua' },
        { name = 'path' },
        { name = 'pandac_reference' },
        { name = 'plugins' },
        { name = 'treesitter' },
        { name = 'tmux' },
        -- {
        --   name = 'look',
        --   keyword_length = 2,
        --   option = {
        --     convert_case = true,
        --     loud = true
        --     --dict = '/usr/share/dict/words'
        --   }
        -- },
        -- { name = 'vsnip' }, -- For vsnip users.
        { name = 'luasnip', option = { use_show_condition = false } }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
      }, {
        { name = 'buffer' },
      }),
      formatting = {
        format = lspkind.cmp_format({
          mode = 'symbol', -- show only symbol annotations
          maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
          ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

          -- The function below will be called before any actual modifications from lspkind
          -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
          before = function(entry, vim_item)
            vim_item.kind = lspkind.symbolic(vim_item.kind, { mode = "symbol" })
            vim_item.menu = (entry == nil and " " or source_mapping[entry.source.name])
            local maxwidth = 80
            vim_item.abbr = string.sub(vim_item.abbr, 1, maxwidth)
            return vim_item
          end
        })
      },
    })
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
  else
    debugger.print('cmp not loaded')
  end

  -- Set configuration for specific filetype.

end

return M
