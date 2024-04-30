local M = {}

---@param names string[]
---@return string[]
local function get_plugin_paths(names)
  local lazypath = vim.fn.stdpath('data') .. "/lazy/"
  local plugins = require("my.plugins").ordinalplugins
  local paths = {}
  for _, name in ipairs(names) do
    if plugins[name] then
      table.insert(paths, plugins[name].dir .. "/lua")
    else
      vim.notify("Invalid plugin name: " .. name)
    end
  end
  return paths
end

---@param plugins string[]
---@return string[]
local function library(plugins)
  -- local paths = get_plugin_paths(plugins)
  local paths = {}
  table.insert(paths, vim.fn.stdpath("data") .. "/lazy/plenary.nvim/lua/luassert")
  table.insert(paths, vim.api.nvim_get_runtime_file("", true))
  table.insert(paths, vim.fn.stdpath("config") .. "/lua")
  table.insert(paths, vim.env.VIMRUNTIME .. "/lua")
  return paths
end

M.sumneko_lua = {
  Lua = {
    diagnostics = {
      enable = true,
      globals = { 'vim', 'it', 'describe', 'before_each', 'after_each' },
      disable = { "lowercase-global" },
    },
    completion = { callSnippet = "Replace" },
    workspace = {
      library = library({ "lazy.nvim" }),
      checkThirdParty = false,
    },
    telemetry = { enable = false },
    runtime = {
      version = "Lua 5.1",
      path = { "?.lua", "?/init.lua" },
    },
    hint = {
      enable = true,
    },
  },
}
return M
-- Lua.completion.autoRequire          default: true
-- Lua.completion.callSnippet          default: "Disable"
-- Lua.completion.displayContext       default: 0
-- Lua.completion.enable               default: true
-- Lua.completion.keywordSnippet       default: "Replace"
-- Lua.completion.postfix              default: "@"
-- Lua.completion.requireSeparator     default: "."
-- Lua.completion.showParams           default: true
-- Lua.completion.showWord             default: "Fallback"
-- Lua.completion.workspaceWord        default: true
-- Lua.diagnostics.disable             default: []
-- Lua.diagnostics.disableScheme       default: ["git"]
-- Lua.diagnostics.enable              default: true
-- Lua.diagnostics.globals             default: []
-- Lua.diagnostics.groupFileStatus
-- Lua.diagnostics.groupSeverity
-- Lua.diagnostics.ignoredFiles        default: "Opened"
-- Lua.diagnostics.libraryFiles        default: "Opened"
-- Lua.diagnostics.neededFileStatus
-- Lua.diagnostics.severity
-- Lua.diagnostics.unusedLocalExclude  default: []
-- Lua.diagnostics.workspaceDelay      default: 3000
-- Lua.diagnostics.workspaceEvent      default: "OnSave"
-- Lua.diagnostics.workspaceRate       default: 100
-- Lua.doc.packageName                 default: []
-- Lua.doc.privateName                 default: []
-- Lua.doc.protectedName               default: []
-- Lua.format.defaultConfig            default: {}
-- Lua.format.enable                   default: true
-- Lua.hint.arrayIndex                 default: "Auto"
-- Lua.hint.await                      default: true
-- Lua.hint.enable                     default: false
-- Lua.hint.paramName                  default: "All"
-- Lua.hint.paramType                  default: true
-- Lua.hint.semicolon                  default: "SameLine"
-- Lua.hint.setType                    default: false
-- Lua.hover.enable                    default: true
-- Lua.hover.enumsLimit                default: 5
-- Lua.hover.expandAlias               default: true
-- Lua.hover.previewFields             default: 50
-- Lua.hover.viewNumber                default: true
-- Lua.hover.viewString                default: true
-- Lua.hover.viewStringMax             default: 1000
-- Lua.misc.executablePath             default: ""
-- Lua.misc.parameters                 default: []
-- Lua.runtime.builtin
-- Lua.runtime.fileEncoding            default: "utf8"
-- Lua.runtime.meta                    default: "${version} ${language} ${encoding}"
-- Lua.runtime.nonstandardSymbol       default: []
-- Lua.runtime.path                    default: ["?.lua","?\/init.lua"]
-- Lua.runtime.pathStrict              default: false
-- Lua.runtime.plugin                  default: ""
-- Lua.runtime.pluginArgs              default: []
-- Lua.runtime.special                 default: {}
-- Lua.runtime.unicodeName             default: false
-- Lua.runtime.version                 default: "Lua 5.4"
-- Lua.semantic.annotation             default: true
-- Lua.semantic.enable                 default: true
-- Lua.semantic.keyword                default: false
-- Lua.semantic.variable               default: true
-- Lua.signatureHelp.enable            default: true
-- Lua.spell.dict                      default: []
-- Lua.telemetry.enable                default: null
-- Lua.type.castNumberToInteger        default: true
-- Lua.type.weakNilCheck               default: false
-- Lua.type.weakUnionCheck             default: false
-- Lua.typeFormat.config
-- Lua.window.progressBar              default: true
-- Lua.window.statusBar                default: true
-- Lua.workspace.checkThirdParty       default: true
-- Lua.workspace.ignoreDir             default: [".vscode"]
-- Lua.workspace.ignoreSubmodules      default: true
-- Lua.workspace.library               default: []
-- Lua.workspace.maxPreload            default: 5000
-- Lua.workspace.preloadFileSize       default: 500
-- Lua.workspace.supportScheme         default: ["file","untitled","git"]
-- Lua.workspace.useGitIgnore          default: true
-- Lua.workspace.userThirdParty        default: []
