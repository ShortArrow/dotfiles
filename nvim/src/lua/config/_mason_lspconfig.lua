local M = {}

local function get_project_root()
  return require("my.utils").project_root()
end

M.setup = function()
  if vim.g.__mason_lspconfig_setup_done then return end
  vim.g.__mason_lspconfig_setup_done = true
  local mason_lspconfig = require("mason-lspconfig")
  local api = require("my")

  -- blink.cmp merges its full capabilities into vim.lsp.config('*') when it
  -- loads; requiring it here instead costs ~1s of UI block on the first
  -- BufReadPre. Advertise the plugin-independent essentials only.
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  -- automatic_enable starts every installed server, so C# would get
  -- csharp_ls + omnisharp(+mono) on the same buffer: triple solution loads
  -- and a flooded UI thread. Keep omnisharp only.
  mason_lspconfig.setup({
    automatic_enable = {
      exclude = { "csharp_ls", "omnisharp_mono" },
    },
  })

  -- On Nvim 0.11+, use vim.lsp.config to resolve configs from nvim-lspconfig's lsp/ directory.

  -- Deduplicate same-named clients per buffer (e.g., duplicate lua_ls)
  local dedup_grp = vim.api.nvim_create_augroup("MyLsp/Dedup", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = dedup_grp,
    callback = function(args)
      local bufnr = args.buf
      local by_name = {}
      for _, c in ipairs(vim.lsp.get_clients({ buffer = bufnr })) do
        if by_name[c.name] then
          pcall(function() c:stop() end)
        else
          by_name[c.name] = true
        end
      end
    end,
  })

  local function setup_server(server_name, opts)
    opts = opts or {}
    opts.capabilities = vim.tbl_deep_extend("force", capabilities, opts.capabilities or {})
    local function canonical_name(name)
      if name == "sumneko_lua" then return "lua_ls" end
      if name == "astro_ls" or name == "astro-ls" then return "astro" end
      if name == "pyls" then return "pylsp" end
      return name
    end
    local cfg_name = canonical_name(server_name)
    opts.name = opts.name or cfg_name
    local config = vim.lsp.config(cfg_name, opts)
    if not config then return end
    local group = vim.api.nvim_create_augroup("MyLspSetup/" .. server_name, { clear = true })
    local fts = config.filetypes or {}

    local function start_for_buf(bufnr)
      local has_same = false
      for _, c in ipairs(vim.lsp.get_clients({ buffer = bufnr })) do
        if c.name == cfg_name then
          has_same = true
          break
        end
      end
      local flag_key = "__lsp_started_" .. cfg_name
      local started_flag = false
      if bufnr and bufnr > 0 then
        started_flag = vim.b[bufnr][flag_key] == true
      end
      if has_same or started_flag then return end

      if bufnr ~= nil and bufnr > 0 then
        vim.b[bufnr][flag_key] = true
      end

      local function resolve_and_start()
        local cfg = vim.deepcopy(config)
        if type(cfg.root_dir) == "function" then
          local resolved
          local target_buf = bufnr or vim.api.nvim_get_current_buf()
          -- Try async signature: function(bufnr, on_dir)
          local ok = pcall(cfg.root_dir, target_buf, function(dir) resolved = dir end)
          if not ok or resolved == nil then
            -- Fall back to sync call: function(fname) -> string
            local fname = vim.api.nvim_buf_get_name(target_buf)
            local ok2, r = pcall(cfg.root_dir, fname)
            if ok2 and type(r) == "string" then resolved = r end
          end
          if type(resolved) == "string" then
            cfg.root_dir = resolved
          else
            -- Last resort: use directory of the current file
            local fname = vim.api.nvim_buf_get_name(target_buf)
            if fname ~= "" then
              cfg.root_dir = vim.fs.dirname(fname)
            else
              cfg.root_dir = vim.fn.getcwd()
            end
          end
        end
        -- lua_ls: skip nvim-specific settings when .luarc.json is present
        if (cfg_name == "lua_ls") and type(cfg.root_dir) == "string" then
          if vim.uv.fs_stat(cfg.root_dir .. "/.luarc.json")
            or vim.uv.fs_stat(cfg.root_dir .. "/.luarc.jsonc") then
            cfg.settings = cfg.settings or {}
            cfg.settings.Lua = vim.empty_dict()
          end
        end
        vim.lsp.start(cfg)
      end

      if bufnr == nil then
        resolve_and_start()
      else
        vim.api.nvim_buf_call(bufnr, resolve_and_start)
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

    -- Retroactively start for already-loaded buffers whose filetype matches.
    -- Needed because mason-lspconfig loads lazily via BufReadPre; the FileType
    -- event may have already fired by the time autocmds are registered.
    vim.schedule(function()
      local ft_set = {}
      for _, ft in ipairs(fts) do ft_set[ft] = true end
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          local buf_ft = vim.bo[buf].filetype
          if #fts == 0 or ft_set[buf_ft] then
            start_for_buf(buf)
          end
        end
      end
    end)
  end

  local function build_opts(server_name)
    local opts = {}
    if server_name == "lua_ls" or server_name == "sumneko_lua" then
      opts.settings = api.lang.lua.sumneko_lua
      opts.root_dir = function(arg1, arg2)
        -- Handle both sync function(fname)->string and async function(bufnr, on_dir)
        local fname
        if type(arg1) == "number" then
          fname = vim.api.nvim_buf_get_name(arg1)
        elseif type(arg1) == "string" then
          fname = arg1
        else
          fname = vim.api.nvim_buf_get_name(0)
        end
        local resolved
        if fname and fname ~= "" then
          -- Prefer the repository root (.git) to match VSCode's workspace
          -- behavior: even when a nested .luarc.json exists, use the repo root.
          resolved = vim.fs.root(fname, ".git")
            or vim.fs.root(fname, {
              ".luarc.json", ".luarc.jsonc", ".luacheckrc",
              ".stylua.toml", "stylua.toml",
              "selene.toml", "selene.yml",
            })
            or vim.fs.dirname(fname)
        else
          resolved = vim.fn.getcwd()
        end
        if type(arg2) == "function" then
          arg2(resolved)
        else
          return resolved
        end
      end
      opts.on_init = function(client)
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc") then
            client.config.settings.Lua = {}
            return
          end
        end
      end

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

    elseif server_name == "kakehashi" then
      opts.cmd = { "kakehashi" }
      -- Restrict to markdown so kakehashi only bridges fenced code blocks.
      -- Letting it attach to .lua/.py/etc. blocks the native LSP from starting.
      opts.filetypes = { "markdown", "markdown_inline" }
      opts.root_dir = function(arg1, arg2)
        -- Handle both sync function(fname)->string and async function(bufnr, on_dir)
        local fname
        if type(arg1) == "number" then
          fname = vim.api.nvim_buf_get_name(arg1)
        elseif type(arg1) == "string" then
          fname = arg1
        else
          fname = vim.api.nvim_buf_get_name(0)
        end
        local resolved
        if fname and fname ~= "" then
          -- Prefer repository root (.git) to match VSCode's workspace behavior
          resolved = vim.fs.root(fname, ".git")
            or vim.fs.root(fname, {
              ".luarc.json", ".luarc.jsonc",
              "pyproject.toml", "package.json", "deno.json", "deno.jsonc",
            })
            or vim.fs.dirname(fname)
        else
          resolved = vim.fn.getcwd()
        end
        if type(arg2) == "function" then
          arg2(resolved)
        else
          return resolved
        end
      end
      -- Auto-detect Mason-installed LSPs from my/lang/*.bridge and wire them
      -- into the kakehashi bridge. init_options is evaluated once at startup;
      -- after installing new LSPs via Mason, run :LspRestart kakehashi to apply.
      local mr = require("mason-registry")
      local bridge = {}
      local language_servers = {}
      for _, lang_cfg in pairs(api.lang) do
        if type(lang_cfg) == "table" and lang_cfg.bridge then
          local b = lang_cfg.bridge
          if mr.is_installed(b.server) then
            language_servers[b.server] = { cmd = b.cmd, languages = b.languages }
            for _, lang in ipairs(b.languages) do
              bridge[lang] = { enabled = true }
            end
          end
        end
      end

      opts.init_options = {
        autoInstall = true,
        languages = { markdown = { bridge = bridge } },
        languageServers = language_servers,
      }
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
