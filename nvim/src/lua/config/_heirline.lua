local M = {}

local function add_color()
  local highlights = require("heirline.highlights")
  local config = require("config._tokyonight")
  local scheme = require("tokyonight.colors").setup(config.config)
  local local_scheme = {
    fg = "#c0caf5",
    bg = "#1e222a",
    cmd_info_bg = "#1e222a",
    cmd_info_fg = "#c0caf5",
    command = "red",
    mod_check = "#c0caf5",
    ui_process_cb = "#c0caf5",
    is_blocking = "#c0caf5",
    diag_ERROR = "#ff0000",
    diag_HINT = "#c0caf5",
    diag_INFO = "#c0caf5",
    diag_WARN = "#ff8800",
    diagnostics_bg = "#1e222a",
    diagnostics_fg = "#c0caf5",
    file_info_bg = "#1e222a",
    file_info_fg = "#c0caf5",
    git_added = "#c0caf5",
    git_branch_bg = "#1e222a",
    git_branch_fg = "#c0caf5",
    git_changed = "#c0caf5",
    git_diff_bg = "#1e222a",
    git_removed = "#c0caf5",
    inactive = "#4b5263",
    insert = "blue",
    lsp_bg = "#1e222a",
    lsp_fg = "#c0caf5",
    mode_fg = "#7aa2f7",
    nav_bg = "#1e222a",
    nav_fg = "#c0caf5",
    normal = "green",
    normal_bg = "#1e222a",
    normal_fg = "#c0caf5",
    scrollbar = "#c0caf5",
    tabline_bg = "blue",
    tabline_fg = "#00caf5",
    terminal = "lime",
    visual = "purple",
    winbar_fg = "#c0caf5",
    winbar_bg = "#1e222a",
  }
  scheme.normal = local_scheme.normal
  scheme.command = local_scheme.command
  scheme.visual = local_scheme.visual
  scheme.insert = local_scheme.insert
  scheme.terminal = local_scheme.terminal
  scheme.inactive = local_scheme.inactive
  scheme.cmd_info_fg = local_scheme.cmd_info_fg
  scheme.cmd_info_bg = scheme.bg
  scheme.mode_fg = local_scheme.mode_fg
  scheme.winbar_fg = local_scheme.winbar_fg
  scheme.tab_fg = local_scheme.fg
  scheme.tab_bg = local_scheme.bg
  scheme.tab_active_fg = scheme.green
  scheme.tab_active_bg = local_scheme.bg
  scheme.tab_close_fg = scheme.red
  scheme.tab_close_bg = local_scheme.bg
  scheme.tabline_fg = local_scheme.tabline_fg
  scheme.tabline_bg = local_scheme.tabline_bg
  scheme.file_info_fg = local_scheme.file_info_fg
  scheme.file_info_bg = scheme.bg
  scheme.git_added = scheme.green
  scheme.git_branch_bg = scheme.bg
  scheme.git_branch_fg = local_scheme.git_branch_fg
  scheme.git_changed = scheme.orange
  scheme.git_diff_bg = scheme.bg
  scheme.git_removed = scheme.red
  scheme.lsp_fg = local_scheme.lsp_fg
  scheme.lsp_bg = scheme.bg
  scheme.nav_fg = local_scheme.nav_fg
  scheme.nav_bg = scheme.bg
  scheme.scrollbar = local_scheme.scrollbar
  scheme.virtual_env_bg = scheme.bg
  scheme.virtual_env_fg = scheme.green
  scheme.diag_ERROR = scheme.red
  scheme.diag_HINT = scheme.purple
  scheme.diag_INFO = scheme.blue
  scheme.diag_WARN = scheme.yellow
  scheme.diagnostics_bg = scheme.bg
  scheme.diagnostics_fg = local_scheme.diagnostics_fg
  highlights.load_colors(scheme)
end

M.opts = function()
  local conditions = require("heirline.conditions")
  local utils = require("heirline.utils")

  -- Ensure safe access to package.loaded
  -- Completely avoid errors when heirline-components checks plugins
  local original_loaded = package.loaded
  local safe_loaded = {}
  setmetatable(safe_loaded, {
    __index = function(t, k)
      local ok, val = pcall(function()
        return original_loaded[k]
      end)
      if ok then
        return val
      else
        return nil
      end
    end,
    __newindex = function(t, k, v)
      original_loaded[k] = v
    end,
  })
  package.loaded = safe_loaded
  
  local lib = require "heirline-components.all"

  -- Show current buffer line ending (LF/CRLF)
  local file_format = {
    provider = function()
      local symbols = { unix = "LF", dos = "CRLF", mac = "CR" }
      local fmt = symbols[vim.bo.fileformat] or vim.bo.fileformat
      return " " .. fmt .. " "
    end,
    hl = { fg = "file_info_fg", bg = "file_info_bg" },
    update = { "BufReadPost", "BufWritePost", "BufEnter", "OptionSet" },
  }
  
  -- Additional safety measures: Override each available check
  if lib.condition then
    -- aerial_available
    if lib.condition.aerial_available then
      local orig = lib.condition.aerial_available
      lib.condition.aerial_available = function()
        local ok, result = pcall(orig)
        return ok and result
      end
    end
    
    -- Protect other plugin available checks similarly
    local condition_funcs = {"conform_available", "neotree_available", "compiler_available"}
    for _, func_name in ipairs(condition_funcs) do
      if lib.condition[func_name] then
        local orig = lib.condition[func_name]
        lib.condition[func_name] = function()
          local ok, result = pcall(orig)
          return ok and result
        end
      end
    end
    
    -- buffer_matches
    if lib.condition.buffer_matches then
      local orig = lib.condition.buffer_matches
      lib.condition.buffer_matches = function(...)
        local ok, result = pcall(orig, ...)
        return ok and result
      end
    end
    
    -- is_active
    if lib.condition.is_active then
      local orig = lib.condition.is_active
      lib.condition.is_active = function(...)
        local ok, result = pcall(orig, ...)
        return ok and result
      end
    end
  end
  
  add_color()
  return {
    opts = {
      disable_winbar_cb = function(args) -- We do this to avoid showing it on the greeter.
        -- Disable during Lazy UI display
        if vim.g.lazy_ui_active then
          return true
        end
        
        -- Safely check conditions
        local ok, is_disabled = pcall(function()
          local buffer = require("heirline-components.buffer")
          if not buffer or not buffer.is_valid then
            return true
          end
          
          local valid = buffer.is_valid(args.buf)
          if not valid then
            return true
          end
          
          if lib.condition and lib.condition.buffer_matches then
            return lib.condition.buffer_matches({
              buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
              filetype = { "NvimTree", "neo%-tree", "dashboard", "Outline", "aerial", "lazy" },
            }, args.buf)
          end
          
          return false
        end)
        
        return not ok or is_disabled
      end,
    },
    tabline = { -- UI upper bar
      lib.component.tabline_conditional_padding(),
      lib.component.tabline_buffers(),
      lib.component.fill { hl = { bg = "tabline_bg" } },
      lib.component.tabline_tabpages(),
    },
    winbar = { -- UI breadcrumbs bar
      init = function(self) 
        -- Skip init during Lazy UI display
        if vim.g.lazy_ui_active then
          return
        end
        self.bufnr = vim.api.nvim_get_current_buf() 
      end,
      fallthrough = false,
      -- Winbar for terminal, neotree, and aerial.
      {
        condition = function() 
          -- Disable during Lazy UI display
          if vim.g.lazy_ui_active then
            return false
          end
          -- Safely check is_active
          local ok, result = pcall(function()
            return lib.condition and lib.condition.is_active and not lib.condition.is_active()
          end)
          return ok and result
        end,
        {
          lib.component.neotree(),
          lib.component.compiler_play(),
          lib.component.fill(),
          lib.component.compiler_build_type(),
          lib.component.compiler_redo(),
          lib.component.aerial(),
        },
      },
      -- Regular winbar
      {
        condition = function()
          -- Disable during Lazy UI display
          return not vim.g.lazy_ui_active
        end,
        lib.component.neotree(),
        lib.component.compiler_play(),
        lib.component.fill(),
        lib.component.breadcrumbs(),
        lib.component.fill(),
        lib.component.compiler_redo(),
        lib.component.aerial(),
      }
    },
    statuscolumn = { -- UI left column
      init = function(self) 
        -- Skip init during Lazy UI display
        if vim.g.lazy_ui_active then
          return
        end
        self.bufnr = vim.api.nvim_get_current_buf() 
      end,
      lib.component.foldcolumn(),
      lib.component.numbercolumn(),
      lib.component.signcolumn(),
    } or nil,
    statusline = {
        {
            condition = function()
                -- Safely execute Lazy UI check
                local ok, is_lazy_active = pcall(function()
                    return vim.g.lazy_ui_active == true
                end)
                return ok and is_lazy_active
            end,
            lib.component.fill(),
        },
        {
            condition = function()
                -- Safely execute Lazy UI check and avoid lib.condition errors
                local ok, is_not_lazy_active = pcall(function()
                    -- Show normal statusline when Lazy UI is disabled or nil
                    return vim.g.lazy_ui_active ~= true
                end)
                -- Also show normal statusline if error occurs
                return ok == false or is_not_lazy_active
            end,
            hl = { fg = "fg", bg = "bg" },
            lib.component.mode(),
            lib.component.git_branch(),
            lib.component.file_info(),
            file_format,
            lib.component.git_diff(),
            lib.component.diagnostics(),
            lib.component.fill(),
            lib.component.cmd_info(),
            lib.component.fill(),
            lib.component.lsp(),
            lib.component.compiler_state(),
            lib.component.virtual_env(),
            lib.component.nav(),
            lib.component.mode { surround = { separator = "right" } },
        },
    },
  }
end

M.config = function(_, opts)
  local heirline = require("heirline")
  local heirline_components = require "heirline-components.all"
  
  -- Make package.loaded metatable safe
  -- Ensure compatibility with lazy.nvim
  if package.loaded then
    local mt = getmetatable(package.loaded) or {}
    local original_index = mt.__index
    mt.__index = function(t, k)
      local ok, result = pcall(function()
        if original_index then
          return original_index(t, k)
        else
          return rawget(t, k)
        end
      end)
      if ok then
        return result
      else
        return nil
      end
    end
    setmetatable(package.loaded, mt)
  end

  -- Temporarily disable heirline when Lazy UI starts
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyStart",
    callback = function()
      vim.g.heirline_disabled = true
    end,
  })
  
  -- Re-enable heirline when Lazy UI ends
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    callback = function()
      vim.g.heirline_disabled = false
      -- Safely update statusline
      pcall(function()
        vim.cmd("redrawstatus!")
      end)
    end,
  })

  -- Setup
  local ok_init = pcall(function()
    heirline_components.init.subscribe_to_events()
  end)
  if not ok_init then
    vim.notify("Heirline components init failed", vim.log.levels.DEBUG)
  end
  
  local ok_colors = pcall(function()
    heirline.load_colors(heirline_components.hl.get_colors())
  end)
  if not ok_colors then
    vim.notify("Heirline colors load failed", vim.log.levels.DEBUG)
  end
  
  -- Add error handling during setup to avoid errors during Lazy UI processing
  local ok_setup = pcall(function()
    heirline.setup(opts)
  end)
  if not ok_setup then
    vim.notify("Heirline setup failed", vim.log.levels.DEBUG)
  end
  
  vim.api.nvim_create_augroup("Heirline", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    pattern = "AstroColorScheme",
    group = "Heirline",
    desc = "Refresh heirline colors",
    callback = function()
      local status = pcall(function()
        heirline_components.hl.get_colors()
      end)
      if not status then
        return
      end
      heirline.reset_highlights()
    end,
  })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = "Heirline",
    callback = function()
      pcall(function()
        utils.on_colorscheme(setup_colors)
      end)
    end,
  })
end

return M
