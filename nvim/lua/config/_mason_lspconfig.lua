local M = {}

local function get_project_root()
  local output = vim.fn.systemlist('git rev-parse --show-toplevel')
  if vim.v.shell_error ~= 0 or #output == 0 then
    return nil
  end
  return output[1]
end

M.setup = function()
  local mason_lspconfig = require("mason-lspconfig")
  local cmp_nvim_lsp = require("cmp_nvim_lsp")
  local api = require("my")

  local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

  mason_lspconfig.setup()

  local has_vim_lsp_config = type(vim.lsp.config) == "function"
  local lspconfig = nil
  if not has_vim_lsp_config then
    pcall(function()
      lspconfig = require("lspconfig")
    end)
  end

  local function setup_server(server_name, opts)
    opts = opts or {}
    opts.capabilities = vim.tbl_deep_extend("force", capabilities, opts.capabilities or {})
    opts.name = opts.name or server_name

    local config
    if has_vim_lsp_config then
      config = vim.lsp.config(server_name, opts)
    else
      if not (lspconfig and lspconfig[server_name]) then
        return
      end
      local defaults = (lspconfig[server_name].document_config and lspconfig[server_name].document_config.default_config) or {}
      config = vim.tbl_deep_extend("force", defaults, opts)
    end
    local group = vim.api.nvim_create_augroup("MyLspSetup/" .. server_name, { clear = true })
    local fts = config.filetypes or {}

    local function start_for_buf(bufnr)
      local has_same = false
      for _, c in ipairs(vim.lsp.get_clients({ buffer = bufnr })) do
        if c.name == server_name then
          has_same = true
          break
        end
      end
      local flag_key = "__lsp_started_" .. server_name
      local started_flag = false
      if bufnr and bufnr > 0 then
        started_flag = vim.b[bufnr][flag_key] == true
      end
      if has_same or started_flag then return end

      if bufnr ~= nil and bufnr > 0 then
        vim.b[bufnr][flag_key] = true
      end

      if bufnr == nil then
        vim.lsp.start(config)
      else
        vim.api.nvim_buf_call(bufnr, function()
          vim.lsp.start(config)
        end)
      end
    end

    if #fts == 0 then
      -- As a fallback, start on BufRead for any buffer (rarely used servers)
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        group = group,
        callback = function(args)
          start_for_buf(args.buf)
        end,
      })
    else
      for _, ft in ipairs(fts) do
        vim.api.nvim_create_autocmd("FileType", {
          group = group,
          pattern = ft,
          callback = function()
            start_for_buf(vim.api.nvim_get_current_buf())
          end,
        })
      end
    end

    -- Do not proactively start for already-open buffers to avoid races; rely on FileType/BufReadPost
  end

  local function build_opts(server_name)
    local opts = {}
    if server_name == "lua_ls" or server_name == "sumneko_lua" then
      opts.settings = api.lang.lua.sumneko_lua

    elseif server_name == "tsserver" then
      if not api.lang.ts.has_package_json() then
        return nil
      end
      opts.settings = api.lang.ts.tsserver
      opts.root_dir = get_project_root()

    elseif server_name == "eslint" then
      opts.root_dir = get_project_root()

    elseif server_name == "denols" then
      if not api.lang.deno.has_deno_json() then
        return nil
      end
      opts.root_dir = get_project_root()
      opts.settings = api.lang.deno.denols

    elseif server_name == "intelephense" then
      opts.settings = api.lang.php.intelephense

    elseif server_name == "lemminx" then
      opts.settings = api.lang.xml.lemminx
      opts.filetypes = api.lang.xml.lemminx.filetypes

    elseif server_name == "pyright" then
      opts = vim.tbl_deep_extend("force", opts, api.lang.python.pyright)

    elseif server_name == "pylsp" or server_name == "pyls" then
      opts.settings = api.lang.python.pylsp

    elseif server_name == "clangd" then
      opts.settings = api.lang.clang.clangd

    elseif server_name == "powershell_es" then
      local pwsh = api.lang.pwsh.powershell_es
      opts = vim.tbl_deep_extend("force", opts, {
        cmd = pwsh.cmd,
        filetypes = pwsh.filetypes,
        settings = { powershell = pwsh.powershell },
      })

    elseif server_name == "astro" or server_name == "astro_ls" or server_name == "astro-ls" then
      opts.settings = api.lang.astro.astro_ls
    end
    return opts
  end

  local installed = mason_lspconfig.get_installed_servers()
  local installed_set = {}
  for _, name in ipairs(installed) do installed_set[name] = true end

  local function start(server_name, opts)
    local o = build_opts(server_name) or {}
    if opts then o = vim.tbl_deep_extend("force", o, opts) end
    setup_server(server_name, o)
  end

  local handlers = {}

  handlers["lua_ls"] = function()
    start("lua_ls")
  end
  handlers["sumneko_lua"] = function()
    if not installed_set["lua_ls"] then start("sumneko_lua") end
  end

  handlers["tsserver"] = function()
    if api.lang.ts.has_package_json() then
      start("tsserver", { root_dir = get_project_root() })
      if installed_set["eslint"] then
        start("eslint", { root_dir = get_project_root() })
      end
    end
  end

  handlers["denols"] = function()
    if (not api.lang.ts.has_package_json()) and api.lang.deno.has_deno_json() then
      start("denols", { root_dir = get_project_root() })
    end
  end

  handlers["pyright"] = function()
    start("pyright")
  end
  handlers["pylsp"] = function()
    if not installed_set["pyright"] then start("pylsp") end
  end
  handlers["pyls"] = function()
    if not installed_set["pyright"] and not installed_set["pylsp"] then start("pyls") end
  end

  handlers["intelephense"] = function()
    start("intelephense")
  end

  handlers["lemminx"] = function()
    start("lemminx")
  end

  handlers["clangd"] = function()
    start("clangd")
  end

  handlers["powershell_es"] = function()
    start("powershell_es")
  end

  handlers["astro"] = function()
    start("astro")
  end
  handlers["astro_ls"] = function()
    if not installed_set["astro"] then start("astro_ls") end
  end
  handlers["astro-ls"] = function()
    if not installed_set["astro"] and not installed_set["astro_ls"] then start("astro-ls") end
  end

  for _, server_name in ipairs(installed) do
    local h = handlers[server_name]
    if h then
      h()
    else
      -- default: start with defaults, if any
      start(server_name)
    end
  end
end

return M
