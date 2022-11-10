local M = {}

M.temp_path = vim.fn.stdpath('cache')

M.bundle_path = vim.fn.resolve(vim.fn.stdpath("data") ..
  "/mason/packages/powershell-editor-services")

M.launcher_path = vim.fn.resolve(vim.fn.stdpath('data') ..
  '/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1')

M.powershell_es = {
  powershell = {
    cwd = './',
    developer = {
      bundledModulesPath = M.bundle_path,
    },
    powerShellExePath = 'pwsh',
  },
  filetypes = { 'powershell', 'ps1' },
  cmd = { 'pwsh', '-NoLogo', '-NoProfile',
    '-Command', M.launcher_path,
    "-BundledModulesPath", M.bundle_path,
    "-LogPath",  M.temp_path .. "/logs.log",
    "-SessionDetailsPath", M.temp_path .. "/session.json",
    "-FeatureFlags", "@()",
    "-AdditionalModules", "@()",
    "-HostName", "nvim",
    "-HostProfileId", "0",
    "-HostVersion", "1.0.0", "-Stdio", "-LogLevel", "Normal" },
  bundle_path = M.bundle_path,
  shell = 'pwsh',
  root_dir = './',
}

return M

-- powershell.analyzeOpenDocumentsOnly                         default: false
-- powershell.bugReporting.project                             default: "https:\/\/github.com\/PowerShell\/vscode-powershell"
-- powershell.buttons.showPanelMovementButtons                 default: false
-- powershell.buttons.showRunButtons                           default: true
-- powershell.codeFolding.enable                               default: true
-- powershell.codeFolding.showLastLine                         default: true
-- powershell.codeFormatting.addWhitespaceAroundPipe           default: true
-- powershell.codeFormatting.alignPropertyValuePairs           default: true
-- powershell.codeFormatting.autoCorrectAliases                default: false
-- powershell.codeFormatting.avoidSemicolonsAsLineTerminators  default: false
-- powershell.codeFormatting.ignoreOneLineBlock                default: true
-- powershell.codeFormatting.newLineAfterCloseBrace            default: true
-- powershell.codeFormatting.newLineAfterOpenBrace             default: true
-- powershell.codeFormatting.openBraceOnSameLine               default: true
-- powershell.codeFormatting.pipelineIndentationStyle          default: "NoIndentation"
-- powershell.codeFormatting.preset                            default: "Custom"
-- powershell.codeFormatting.trimWhitespaceAroundPipe          default: false
-- powershell.codeFormatting.useConstantStrings                default: false
-- powershell.codeFormatting.useCorrectCasing                  default: false
-- powershell.codeFormatting.whitespaceAfterSeparator          default: true
-- powershell.codeFormatting.whitespaceAroundOperator          default: true
-- powershell.codeFormatting.whitespaceAroundPipe              default: true
-- powershell.codeFormatting.whitespaceBeforeOpenBrace         default: true
-- powershell.codeFormatting.whitespaceBeforeOpenParen         default: true
-- powershell.codeFormatting.whitespaceBetweenParameters       default: false
-- powershell.codeFormatting.whitespaceInsideBrace             default: true
-- powershell.cwd                                              default: ""
-- powershell.debugging.createTemporaryIntegratedConsole       default: false
-- powershell.developer.bundledModulesPath                     default: "..\/..\/PowerShellEditorServices\/module"
-- powershell.developer.editorServicesLogLevel                 default: "Normal"
-- powershell.developer.editorServicesWaitForDebugger          default: false
-- powershell.developer.featureFlags                           default: []
-- powershell.developer.waitForSessionFileTimeoutSeconds       default: 240
-- powershell.enableProfileLoading                             default: true
-- powershell.enableReferencesCodeLens                         default: true
-- powershell.helpCompletion                                   default: "BlockComment"
-- powershell.integratedConsole.focusConsoleOnExecute          default: true
-- powershell.integratedConsole.forceClearScrollbackBuffer     default: false
-- powrshell.integratedConsole.showOnStartup                  default: true
-- powershell.integratedConsole.startInBackground              default: false
-- powershell.integratedConsole.suppressStartupBanner          default: false
-- powershell.integratedConsole.useLegacyReadLine              default: false
-- powershell.pester.codeLens                                  default: true
-- powershell.pester.debugOutputVerbosity                      default: "Diagnostic"
-- powershell.pester.outputVerbosity                           default: "FromPreference"
-- powershell.pester.useLegacyCodeLens                         default: true
-- powershell.powerShellAdditionalExePaths                     default: {}
-- powershell.powerShellDefaultVersion                         default: ""
-- powershell.powerShellExePath                                default: ""
-- powershell.promptToUpdatePackageManagement                  default: false
-- powershell.promptToUpdatePowerShell                         default: true
-- powershell.scriptAnalysis.enable                            default: true
-- powershell.scriptAnalysis.settingsPath                      default: "PSScriptAnalyzerSettings.psd1"
-- powershell.sideBar.CommandExplorerExcludeFilter             default: []
-- powershell.sideBar.CommandExplorerVisibility                default: true
-- powershell.startAsLoginShell.linux                          default: false
-- powershell.startAsLoginShell.osx                            default: true
-- powershell.startAutomatically                               default: true
-- powershell.useX86Host                                       default: false
