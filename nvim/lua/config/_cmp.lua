local api = require("my")
local debugger = api.debugger

local M = {}

M.setup = function()
  vim.o.completeopt = "menu,menuone,noselect"
  -- Setup nvim-cmp.
  local lspkind_ok, lspkind = pcall(require, "lspkind")
  local luasnip_ok, luasnip = pcall(require, "luasnip")
  if not lspkind_ok then
    return
  end
  if not luasnip_ok then
    return
  end

  local source_mapping = {
    buffer = "[Buffer]",
    nvim_lsp = "[LSP]",
    nvim_lua = "[Lua]",
    treesitter = "[🌳TS]",
    plugins = "[Plugins]",
    vsnip = "[VSnip]",
    path = "[Path]",
    calc = "[Calc]",
    emoji = "[Emoji]",
    nerdfont = "[Nerd]",
    nvim_lsp_signature_help = "[Signature]",
    pandac_reference = "[Pandac]",
    tmux = "[TMUX]",
  }
  local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local cmp = require("cmp")
  -- If you want insert `(` after select function or method item
  local autopairs_ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
  local handers_ok, handlers = pcall(require, "nvim-autopairs.completion.handlers")
  if autopairs_ok then
    if handers_ok then
      cmp.event:on(
        "confirm_done",
        cmp_autopairs.on_confirm_done({
          filetypes = {
            -- "*" is a alias to all filetypes
                ["*"] = {
                  ["("] = {
                kind = {
                  cmp.lsp.CompletionItemKind.Function,
                  cmp.lsp.CompletionItemKind.Method,
                },
                handler = handlers["*"],
              },
            },
            lua = {
                  ["("] = {
                kind = {
                  cmp.lsp.CompletionItemKind.Function,
                  cmp.lsp.CompletionItemKind.Method,
                },
                ---@param char string
                ---@param item table item completion
                ---@param bufnr number buffer number
                ---@param rules table
                ---@param commit_character table<string>
                handler = function(char, item, bufnr, rules, commit_character)
                  -- Your handler function. Inpect with print(vim.inspect{char, item, bufnr, rules, commit_character})
                end,
              },
            },
            -- Disable for tex
            tex = false,
          },
        })
      )
    else
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  else
    print("can't require() nvim-autopairs", cmp_autopairs)
  end
  if cmp ~= nil then
    cmp.setup({
      enabled = function()
        if vim.bo.buftype == 'prompt' then
          return false
        end
        local context = require("cmp.config.context")
        local function is_emoji()
          return vim.api.nvim_get_current_line():match("^.*:[%w%-_]*$") ~= nil
        end
        -- disable completion in dart language
        if vim.tbl_contains({ "dart" }, vim.bo.filetype) then
          return false
        end
        -- enable completion in comments for emoji 😄
        if is_emoji() then
          return true
        end
        -- disable completion in comments
        if vim.api.nvim_get_mode().mode == "c" then
          return true
        else
          return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
        end
      end,
      sorting = {
        priority_weight = 2,
        -- comparators = {
        --   compare.offset,
        --   compare.exact,
        --   compare.score,
        --   compare.recently_used,
        --   compare.kind,
        --   compare.sort_text,
        --   compare.length,
        --   compare.order,
        -- },
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      view = {
        entries = { name = "custom", selection_order = "near_cursor" },
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
            ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
            ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
            ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
            ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
            ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
            ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
            ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
            ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
            ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
            ["<C-y>"] = cmp.config.disable,
            ["<C-e>"] = cmp.mapping({
          i = cmp.mapping.abort(),
          c = cmp.mapping.close(),
        }),
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
            ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expandable() then
            luasnip.expand()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "calc" },
        { name = "emoji",                  max_item_count = 10 },
        { name = "nerdfont",               max_item_count = 10 },
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "nvim_lua" },
        { name = "path" },
        { name = "pandac_reference" },
        { name = "plugins" },
        { name = "treesitter" },
        { name = "tmux" },
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
        { name = "luasnip",                option = { use_show_condition = false } }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
      }, {
        { name = "buffer" },
      }),
      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text", --  options: 'text', 'text_symbol', 'symbol_text', 'symbol'
          with_text = false,
          maxwidth = 50,    -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
          ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
          -- The function below will be called before any actual modifications from lspkind
          -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
          before = function(entry, vim_item)
            if vim.tbl_contains({ "path" }, entry.source.name) then
              local icon, hl_group =
                  require("nvim-web-devicons").get_icon(entry:get_completion_item().label)
              if icon then
                vim_item.kind = icon .. " "
                vim_item.kind_hl_group = hl_group
                return vim_item
              end
            end
            -- vim_item.kind = lspkind.symbolic(vim_item.kind, { mode = "symbol" })
            vim_item.menu = (entry == nil and " " or source_mapping[entry.source.name])
            local maxwidth = 80
            vim_item.abbr = string.sub(vim_item.abbr, 1, maxwidth)
            return vim_item
          end,
        }),
      },
    })
    cmp.setup.filetype("gitcommit", {
      sources = cmp.config.sources({
        { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
      }, {
        { name = "buffer" },
      }),
    })

    -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
    })
  else
    debugger.print("cmp not loaded")
  end

  -- Set configuration for specific filetype.
end

return M
