local M = {}

function M.setup()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true;
  -- flutter-tools
  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
      vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    client.server_capabilities.documentFormattingProvider = true

    local opts = { noremap = true, silent = true }
    buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    buf_set_keymap("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
    buf_set_keymap("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
    buf_set_keymap("n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
    buf_set_keymap("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    buf_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    buf_set_keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    buf_set_keymap("n", "<leader>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
    buf_set_keymap("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
    buf_set_keymap("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
    buf_set_keymap("n", "<leader>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
    buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end
  local config = {
      lsp = {
          color = {
              enabled = true,
              background = true,
              foreground = false,
              virtual_text = true,
              virtual_text_str = "■",
          },
          on_attach = function(client, bufnr)
            vim.cmd [[hi FlutterWidgetGuides ctermfg=237 guifg=#33374c]]
            vim.cmd [[hi ClosingTags ctermfg=244 guifg=#8389a3]]
            on_attach(client, bufnr)
          end,
          capabilities = capabilities,
          widget_guides = {
              enabled = true,
          },
          settings = {
              showTodos = true,
              completeFunctionCalls = true,
              -- analysisExcludedFolders = { "<path-to-flutter-sdk-packages>" },
              renameFilesWithClasses = "prompt", -- "always"
              enableSnippets = true,
          },
          debugger = {
              enabled = false,
              register_configurations = function(_)
                require("dap").configurations.dart = {}
                require("dap.ext.vscode").load_launchjs()
              end,
          },
      }
  }
  require("flutter-tools").setup(config)
  vim.api.nvim_set_keymap('n', '<Leader>fr', ':FlutterRun -d web-server<CR>'
      , { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<Leader>fc',
      [[<Cmd>lua require('telescope').extensions.flutter.commands()<CR>]],
      { noremap = true, silent = true })
end

return M
