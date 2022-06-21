local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true;
-- flutter-tools
require("flutter-tools").setup{
  lsp = {
    color = {
      enabled = true,
      background = true, 
      foreground = true,
      virtual_text = true,
      virtual_text_str = "■",
    },
    on_attach = function(client, bufnr)
      vim.cmd [[hi FlutterWidgetGuides ctermfg=237 guifg=#33374c]]
      vim.cmd [[hi ClosingTags ctermfg=244 guifg=#8389a3]]
      on_attach(client, bufnr)
    end,
    cadependenciespabilities = capabilities,
    widget_guides = {
      enabled = true,
    },
    debugger = {
    enabled = true,
      register_configurations = function(_)
        require("dap").configurations.dart = {}
        require("dap.ext.vscode").load_launchjs()
      end,
    },
  }
}
