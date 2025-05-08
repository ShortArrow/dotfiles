local M = {}

M.setup = function()
  local lspconfig = require("lspconfig")
  local mason_lspconfig = require("mason-lspconfig")
  local _api = require('my')
  local _nvim_lsp = require('lspconfig')
  local _mason_lspconfig = require('mason-lspconfig')
  local _lsp_sig = require('lsp_signature')

  mason_lspconfig.setup()
  -- mason_lspconfig.setup_handlers({
  --   function(server_name)
  --     local _opts = {}
  --     if server_name == "sumneko_lua" then
  --       _opts.settings = _api.lang.lua.sumneko_lua
  --     elseif server_name == "tsserver" then
  --       if not _api.lang.ts.has_package_json() then
  --         return
  --       else
  --         _opts.root_dir = get_project_root
  --         _opts.settings = _api.lang.ts.tsserver
  --       end
  --     elseif server_name == "eslint" then
  --       _opts.root_dir = get_project_root
  --     elseif server_name == "denols" then
  --       if not _api.lang.deno.has_deno_json() then
  --         return
  --       else
  --         _opts.root_dir = get_project_root
  --         _opts.settings = _api.lang.deno.denols
  --       end
  --       -- _opts.init_options = {
  --       --   lint = true,
  --       --   unstable = true,
  --       --   suggest = {
  --       --     imports = {
  --       --       hosts = {
  --       --         ["https://deno.land"] = true,
  --       --         ["https://cdn.nest.land"] = true,
  --       --         ["https://crux.land"] = true
  --       --       }
  --       --     }
  --       --   }
  --       -- }
  --     elseif server_name == "intelephense" then
  --       _opts.settings = _api.lang.php.intelephense
  --     elseif server_name == "lemminx" then
  --       _opts.settings = _api.lang.xml.lemminx
  --       _opts.filetypes = { "xml", "xsl", "xsd", "xaml" }
  --     elseif server_name == "pyright" then
  --       _opts.settings = _api.lang.python.pyright
  --     elseif server_name == "pyls" then
  --       _opts.settings = _api.lang.python.pylsp
  --     elseif server_name == "clangd" then
  --       _opts.settings = _api.lang.clang.clangd
  --     elseif server_name == "powershell_es" then
  --       _opts.settings = _api.lang.pwsh.powershell_es
  --     elseif server_name == "astro-ls" then
  --       _opts.settings = _api.lang.astro.astro_ls
  --     end
  --     _opts.capabilities = capabilities
  --     _opts.capabilities.offsetEncoding = { 'utf-16' } -- this is temporary patch https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
  --     _opts.on_attach = function(_, bufnr)
  --       _lsp_sig.on_attach(M.lsp_sig_config, bufnr)
  --     end
  --     _nvim_lsp[server_name].setup(_opts)
  --   end
  -- })
end

return M
