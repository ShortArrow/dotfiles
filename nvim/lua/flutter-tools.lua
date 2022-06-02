-- fern-renderer-nerdfont
local fern-renderer-nerdfont = {}
fern-renderer-nerdfont.config = function()
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
      capabilities = capabilities,
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
end
return fern-renderer-nerdfont
