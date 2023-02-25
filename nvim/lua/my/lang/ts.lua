local M = {}

M.tsserver = {
  javascript = {
    inlayHints = {
      parameterTypes = { enabled = true },
    },
  },
}

M.has_package_json = function()
  local output = vim.fn.systemlist('git rev-parse --show-toplevel') -- プロジェクトルートのパスを取得
  if vim.v.shell_error ~= 0 or #output == 0 then
    return false
  end

  local package_json_path = table.concat({ output[1], 'package.json' }, '/') -- パスを結合して package.json のパスを作成
  return vim.fn.filereadable(package_json_path) ~= 0 -- package.json が存在する場合は真を返す
end

M.get_package_json_path = function()
  local output = vim.fn.systemlist('git rev-parse --show-toplevel')
  if vim.v.shell_error ~= 0 or #output == 0 then
    return nil
  end

  local package_json_path = table.concat({ output[1], 'package.json' }, '/')
  if vim.fn.filereadable(package_json_path) == 0 then
    return nil
  end

  return package_json_path
end

return M
-- javascript.autoClosingTags                                                     default: true
-- javascript.format.enable                                                       default: true
-- javascript.format.insertSpaceAfterCommaDelimiter                               default: true
-- javascript.format.insertSpaceAfterConstructor                                  default: false
-- javascript.format.insertSpaceAfterFunctionKeywordForAnonymousFunctions         default: true
-- javascript.format.insertSpaceAfterKeywordsInControlFlowStatements              default: true
-- javascript.format.insertSpaceAfterOpeningAndBeforeClosingEmptyBraces           default: true
-- javascript.format.insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces   default: false
-- javascript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces        default: true
-- javascript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets      default: false
-- javascript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis   default: false
-- javascript.format.insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces  default: false
-- javascript.format.insertSpaceAfterSemicolonInForStatements                     default: true
-- javascript.format.insertSpaceBeforeAndAfterBinaryOperators                     default: true
-- javascript.format.insertSpaceBeforeFunctionParenthesis                         default: false
-- javascript.format.placeOpenBraceOnNewLineForControlBlocks                      default: false
-- javascript.format.placeOpenBraceOnNewLineForFunctions                          default: false
-- javascript.format.semicolons                                                   default: "ignore"
-- javascript.implicitProjectConfig.checkJs                                       default: false
-- javascript.implicitProjectConfig.experimentalDecorators                        default: false
-- javascript.inlayHints.enumMemberValues.enabled                                 default: false
-- javascript.inlayHints.functionLikeReturnTypes.enabled                          default: false
-- javascript.inlayHints.parameterNames.enabled                                   default: "none"
-- javascript.inlayHints.parameterNames.suppressWhenArgumentMatchesName           default: true
-- javascript.inlayHints.parameterTypes.enabled                                   default: false
-- javascript.inlayHints.propertyDeclarationTypes.enabled                         default: false
-- javascript.inlayHints.variableTypes.enabled                                    default: false
-- javascript.inlayHints.variableTypes.suppressWhenTypeMatchesName                default: true
-- javascript.preferences.autoImportFileExcludePatterns
-- javascript.preferences.importModuleSpecifier                                   default: "shortest"
-- javascript.preferences.importModuleSpecifierEnding                             default: "auto"
-- javascript.preferences.jsxAttributeCompletionStyle                             default: "auto"
-- javascript.preferences.quoteStyle                                              default: "auto"
-- javascript.preferences.renameShorthandProperties                               default: true
-- javascript.preferences.useAliasesForRenames                                    default: true
-- javascript.referencesCodeLens.enabled                                          default: false
-- javascript.referencesCodeLens.showOnAllFunctions                               default: false
-- javascript.suggest.autoImports                                                 default: true
-- javascript.suggest.classMemberSnippets.enabled                                 default: true
-- javascript.suggest.completeFunctionCalls                                       default: false
-- javascript.suggest.completeJSDocs                                              default: true
-- javascript.suggest.enabled                                                     default: true
-- javascript.suggest.includeAutomaticOptionalChainCompletions                    default: true
-- javascript.suggest.includeCompletionsForImportStatements                       default: true
-- javascript.suggest.jsdoc.generateReturns                                       default: true
-- javascript.suggest.names                                                       default: true
-- javascript.suggest.paths                                                       default: true
-- javascript.suggestionActions.enabled                                           default: true
-- javascript.updateImportsOnFileMove.enabled                                     default: "prompt"
-- javascript.validate.enable                                                     default: true
-- js/ts.implicitProjectConfig.checkJs                                            default: false
-- js/ts.implicitProjectConfig.experimentalDecorators                             default: false
-- js/ts.implicitProjectConfig.module                                             default: "ESNext"
-- js/ts.implicitProjectConfig.strictFunctionTypes                                default: true
-- js/ts.implicitProjectConfig.strictNullChecks                                   default: true
-- js/ts.implicitProjectConfig.target                                             default: "ES2020"
-- typescript.autoClosingTags                                                     default: true
-- typescript.check.npmIsInstalled                                                default: true
-- typescript.disableAutomaticTypeAcquisition                                     default: false
-- typescript.enablePromptUseWorkspaceTsdk                                        default: false
-- typescript.format.enable                                                       default: true
-- typescript.format.insertSpaceAfterCommaDelimiter                               default: true
-- typescript.format.insertSpaceAfterConstructor                                  default: false
-- typescript.format.insertSpaceAfterFunctionKeywordForAnonymousFunctions         default: true
-- typescript.format.insertSpaceAfterKeywordsInControlFlowStatements              default: true
-- typescript.format.insertSpaceAfterOpeningAndBeforeClosingEmptyBraces           default: true
-- typescript.format.insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces   default: false
-- typescript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces        default: true
-- typescript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets      default: false
-- typescript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis   default: false
-- typescript.format.insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces  default: false
-- typescript.format.insertSpaceAfterSemicolonInForStatements                     default: true
-- typescript.format.insertSpaceAfterTypeAssertion                                default: false
-- typescript.format.insertSpaceBeforeAndAfterBinaryOperators                     default: true
-- typescript.format.insertSpaceBeforeFunctionParenthesis                         default: false
-- typescript.format.placeOpenBraceOnNewLineForControlBlocks                      default: false
-- typescript.format.placeOpenBraceOnNewLineForFunctions                          default: false
-- typescript.format.semicolons                                                   default: "ignore"
-- typescript.implementationsCodeLens.enabled                                     default: false
-- typescript.inlayHints.enumMemberValues.enabled                                 default: false
-- typescript.inlayHints.functionLikeReturnTypes.enabled                          default: false
-- typescript.inlayHints.parameterNames.enabled                                   default: "none"
-- typescript.inlayHints.parameterNames.suppressWhenArgumentMatchesName           default: true
-- typescript.inlayHints.parameterTypes.enabled                                   default: false
-- typescript.inlayHints.propertyDeclarationTypes.enabled                         default: false
-- typescript.inlayHints.variableTypes.enabled                                    default: false
-- typescript.inlayHints.variableTypes.suppressWhenTypeMatchesName                default: true
-- typescript.locale                                                              default: "auto"
-- typescript.npm
-- typescript.preferences.autoImportFileExcludePatterns
-- typescript.preferences.importModuleSpecifier                                   default: "shortest"
-- typescript.preferences.importModuleSpecifierEnding                             default: "auto"
-- typescript.preferences.includePackageJsonAutoImports                           default: "auto"
-- typescript.preferences.jsxAttributeCompletionStyle                             default: "auto"
-- typescript.preferences.quoteStyle                                              default: "auto"
-- typescript.preferences.renameShorthandProperties                               default: true
-- typescript.preferences.useAliasesForRenames                                    default: true
-- typescript.referencesCodeLens.enabled                                          default: false
-- typescript.referencesCodeLens.showOnAllFunctions                               default: false
-- typescript.reportStyleChecksAsWarnings                                         default: true
-- typescript.suggest.autoImports                                                 default: true
-- typescript.suggest.classMemberSnippets.enabled                                 default: true
-- typescript.suggest.completeFunctionCalls                                       default: false
-- typescript.suggest.completeJSDocs                                              default: true
-- typescript.suggest.enabled                                                     default: true
-- typescript.suggest.includeAutomaticOptionalChainCompletions                    default: true
-- typescript.suggest.includeCompletionsForImportStatements                       default: true
-- typescript.suggest.includeCompletionsWithSnippetText                           default: true
-- typescript.suggest.jsdoc.generateReturns                                       default: true
-- typescript.suggest.objectLiteralMethodSnippets.enabled                         default: true
-- typescript.suggest.paths                                                       default: true
-- typescript.suggestionActions.enabled                                           default: true
-- typescript.surveys.enabled                                                     default: true
-- typescript.tsc.autoDetect                                                      default: "on"
-- typescript.tsdk
-- typescript.tsserver.enableTracing                                              default: false
-- typescript.tsserver.experimental.enableProjectDiagnostics                      default: false
-- typescript.tsserver.log                                                        default: "off"
-- typescript.tsserver.maxTsServerMemory                                          default: 3072
-- typescript.tsserver.pluginPaths                                                default: []
-- typescript.tsserver.trace                                                      default: "off"
-- typescript.tsserver.useSeparateSyntaxServer                                    default: true
-- typescript.tsserver.useSyntaxServer                                            default: "auto"
-- typescript.tsserver.watchOptions
-- typescript.updateImportsOnFileMove.enabled                                     default: "prompt"
-- typescript.validate.enable                                                     default: true
-- typescript.workspaceSymbols.scope                                              default: "allOpenProjects"
