local api = require('my.api')
local debugger = api.debugger

local M = {}

M.setup = function()
  vim.o.completeopt = 'menu,menuone,noselect'
  -- Setup nvim-cmp.
  local lspkind = require('lspkind')
  local compare = require('cmp.config.compare')
  local source_mapping = {
    buffer = "[Buffer]",
    nvim_lsp = "[LSP]",
    nvim_lua = "[Lua]",
    cmp_tabnine = "[TN]",
    treesitter = "[TS]",
    plugins = "[Plugins]",
    vsnip = "[VSnip]",
    path = "[Path]",
  }
  local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")
  local cmp = require('cmp')
  if cmp ~= nil then
    cmp.setup({
      sorting = {
        priority_weight = 2,
        comparators = {
          require('cmp_tabnine.compare'),
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
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          vim.fn["UltiSnips#Anon"](args.body)
          -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
          -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
      },
      window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        -- ['<Tab>'] = function(fallback)
        --   if cmp.visible() then
        --     cmp.select_next_item()
        --   else
        --     fallback()
        --   end
        -- end,
        -- ['<S-Tab>'] = function(fallback)
        --   if cmp.visivle() then
        --     cmp.select_prev_item()
        --   else
        --     fallback()
        --   end
        -- end,
        ["<Tab>"] = cmp.mapping(
          function(fallback)
            cmp_ultisnips_mappings.expand_or_jump_forwards(fallback)
          end,
          { "i", "s", --[[ "c" (to enable the mapping in command mode) ]] }
        ),
        ["<S-Tab>"] = cmp.mapping(
          function(fallback)
            cmp_ultisnips_mappings.jump_backwards(fallback)
          end,
          { "i", "s", --[[ "c" (to enable the mapping in command mode) ]] }
        ),
      }),
      sources = cmp.config.sources({
        { name = 'calc' },
        { name = 'cmp_tabnine' },
        { name = 'emoji' },
        { name = 'nerdfont' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lsp_signature_help' },
        { name = 'nvim_lua' },
        { name = 'pandac_reference' },
        { name = 'plugins' },
        { name = 'treesitter' },
        { name = 'tmux' },
        {
          name = 'look',
          keyword_length = 2,
          option = {
            convert_case = true,
            loud = true
            --dict = '/usr/share/dict/words'
          }
        },
        { name = 'vsnip' }, -- For vsnip users.
        -- { name = 'luasnip' }, -- For luasnip users.
        { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
      }, {
        { name = 'buffer' },
      }),
      formatting = {
        format = function(entry, vim_item)
          -- if you have lspkind installed, you can use it like
          -- in the following line:
          vim_item.kind = lspkind.symbolic(vim_item.kind, { mode = "symbol" })
          vim_item.menu = source_mapping[entry.source.name]
          if entry.source.name == "cmp_tabnine" then
            local detail = (entry.completion_item.data or {}).detail
            vim_item.kind = ""
            if detail and detail:find('.*%%.*') then
              vim_item.kind = vim_item.kind .. ' ' .. detail
            end

            if (entry.completion_item.data or {}).multiline then
              vim_item.kind = vim_item.kind .. ' ' .. '[ML]'
            end
          end
          local maxwidth = 80
          vim_item.abbr = string.sub(vim_item.abbr, 1, maxwidth)
          return vim_item
        end,
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
