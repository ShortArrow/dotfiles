local M = {}

local function set_win32yank()
  local user = os.getenv("WIN_USER") or os.getenv("USERNAME")
  local scoop = user and ("/mnt/c/Users/" .. user .. "/scoop/shims/win32yank.exe") or nil
  local choco = "/mnt/c/ProgramData/chocolatey/bin/win32yank.exe"

  local exe = nil
  if scoop and vim.uv.fs_stat(scoop) then
    exe = scoop
  elseif vim.uv.fs_stat(choco) then
    exe = choco
  elseif vim.fn.executable("win32yank.exe") == 1 then
    exe = "win32yank.exe"
  end

  if not exe then
    return
  end

  vim.g.clipboard = {
    name = "win32yank",
    copy = {
      ["+"] = { exe, "-i", "--crlf" },
      ["*"] = { exe, "-i", "--crlf" },
    },
    paste = {
      ["+"] = { exe, "-o", "--lf" },
      ["*"] = { exe, "-o", "--lf" },
    },
    cache_enabled = 1,
  }
end

local function set_wl_clipboard()
  if vim.fn.executable("wl-copy") ~= 1 or vim.fn.executable("wl-paste") ~= 1 then
    return
  end

  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ["+"] = { "wl-copy", "--foreground", "--type", "text/plain" },
      ["*"] = { "wl-copy", "--foreground", "--type", "text/plain" },
    },
    paste = {
      ["+"] = { "wl-paste", "--no-newline" },
      ["*"] = { "wl-paste", "--no-newline" },
    },
    cache_enabled = 1,
  }
end

local function set_x11_clipboard()
  if vim.fn.executable("xclip") == 1 then
    vim.g.clipboard = {
      name = "xclip",
      copy = {
        ["+"] = { "xclip", "-selection", "clipboard" },
        ["*"] = { "xclip", "-selection", "primary" },
      },
      paste = {
        ["+"] = { "xclip", "-selection", "clipboard", "-o" },
        ["*"] = { "xclip", "-selection", "primary", "-o" },
      },
      cache_enabled = 1,
    }
    return
  end

  if vim.fn.executable("xsel") == 1 then
    vim.g.clipboard = {
      name = "xsel",
      copy = {
        ["+"] = { "xsel", "--clipboard", "--input" },
        ["*"] = { "xsel", "--primary", "--input" },
      },
      paste = {
        ["+"] = { "xsel", "--clipboard", "--output" },
        ["*"] = { "xsel", "--primary", "--output" },
      },
      cache_enabled = 1,
    }
  end
end

function M.setup()
  if vim.fn.has("wsl") == 1 then
    set_win32yank()
    return
  end

  if vim.fn.has("win32") == 1 then
    set_win32yank()
    return
  end

  local session = (os.getenv("XDG_SESSION_TYPE") or ""):lower()
  if os.getenv("WAYLAND_DISPLAY") or session == "wayland" then
    set_wl_clipboard()
    if vim.g.clipboard then return end
  end

  if os.getenv("DISPLAY") or session == "x11" then
    set_x11_clipboard()
  end
end

return M
