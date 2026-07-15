local M = {}

-- Completion setup for blink.cmp, replacing the previous nvim-cmp stack.
--
-- LSP capabilities are wired separately in _mason_lspconfig.lua via
-- require("blink.cmp").get_lsp_capabilities(), so this module only
-- configures the completion UI, keymaps, and sources.
--
-- Native blink sources (lsp/path/snippets/buffer) and Copilot
-- (blink-copilot) are provided directly. Legacy cmp sources
-- (calc/emoji/nerdfont/pandoc_references/plugins) are bridged through
-- blink.compat. Sources dropped in the migration (treesitter, tmux,
-- nvim_lua, signature_help) are intentionally absent -- their plugins
-- are no longer installed.

M.setup = function()
  require("blink.cmp").setup({
    snippets = { preset = "luasnip" },

    -- Keymaps ported from the previous nvim-cmp mappings.
    keymap = {
      preset = "none",
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-d>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },

    appearance = {
      -- blink ships its own kind icons, so lspkind.nvim is no longer needed.
      nerd_font_variant = "mono",
    },

    completion = {
      documentation = { auto_show = true },
      menu = {
        draw = {
          columns = {
            { "kind_icon" },
            { "label", "label_description", gap = 1 },
            { "source_name" },
          },
        },
      },
    },

    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        "copilot",
        "calc",
        "emoji",
        "nerdfont",
        "pandoc_references",
        "plugins",
      },
      providers = {
        copilot = {
          name = "copilot",
          module = "blink-copilot",
          score_offset = 100,
          async = true,
        },
        calc = { name = "calc", module = "blink.compat.source" },
        emoji = { name = "emoji", module = "blink.compat.source", max_items = 10 },
        nerdfont = { name = "nerdfont", module = "blink.compat.source", max_items = 10 },
        pandoc_references = { name = "pandoc_references", module = "blink.compat.source" },
        plugins = { name = "plugins", module = "blink.compat.source" },
      },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" },
  })
end

return M
