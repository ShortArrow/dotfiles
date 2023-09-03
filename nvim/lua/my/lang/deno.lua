local M = {}

M.denols = {
  deno = {
    enable = true,
    lint = true,
    unstable = true,
    importMap = "./import_map.json",
    config = "./deno.json"
  }
}

M.has_deno_json = function()
  local output = vim.fn.systemlist('git rev-parse --show-toplevel') -- プロジェクトルートのパスを取得
  if vim.v.shell_error ~= 0 or #output == 0 then
    return false
  end

  local package_json_path = table.concat({ output[1], 'deno.json' }, '/') -- パスを結合して deno.json のパスを作成
  return vim.fn.filereadable(package_json_path) ~= 0                      -- package.json が存在する場合は真を返す
end

M.get_deno_json_path = function()
  local output = vim.fn.systemlist('git rev-parse --show-toplevel')
  if vim.v.shell_error ~= 0 or #output == 0 then
    return nil
  end

  local package_json_path = table.concat({ output[1], 'deno.json' }, '/')
  if vim.fn.filereadable(package_json_path) == 0 then
    return nil
  end

  return package_json_path
end

return M
-- → deno.cache                                                      default: null
-- → deno.certificateStores                                          default: null
-- → deno.codeLens.implementations                                   default: false
-- → deno.codeLens.references                                        default: false
-- → deno.codeLens.referencesAllFunctions                            default: false
-- → deno.codeLens.test                                              default: false
-- → deno.codeLens.testArgs                                          default: ["--allow-all","--no-check"]
-- → deno.config                                                     default: null
-- → deno.enable                                                     default: false
-- → deno.enablePaths                                                default: []
-- → deno.importMap                                                  default: null
-- → deno.inlayHints.enumMemberValues.enabled                        default: false
-- → deno.inlayHints.functionLikeReturnTypes.enabled                 default: false
-- → deno.inlayHints.parameterNames.enabled                          default: "none"
-- → deno.inlayHints.parameterNames.suppressWhenArgumentMatchesName  default: true
-- → deno.inlayHints.parameterTypes.enabled                          default: false
-- → deno.inlayHints.propertyDeclarationTypes.enabled                default: false
-- → deno.inlayHints.variableTypes.enabled                           default: false
-- → deno.inlayHints.variableTypes.suppressWhenTypeMatchesName       default: true
-- → deno.internalDebug                                              default: false
-- → deno.lint                                                       default: true
-- → deno.path                                                       default: null
-- → deno.suggest.autoImports                                        default: true
-- → deno.suggest.completeFunctionCalls                              default: false
-- → deno.suggest.imports.autoDiscover                               default: true
-- → deno.suggest.imports.hosts                                      default: {"https:\/\/crux.land":true,"https:\/\/deno.land":true,"https:\/\/x.nest.land":true}
-- → deno.suggest.names                                              default: true
-- → deno.suggest.paths                                              default: true
-- → deno.testing.args                                               default: ["--allow-all","--no-check"]
-- → deno.testing.enable                                             default: true
-- → deno.tlsCertificate                                             default: null
-- → deno.unsafelyIgnoreCertificateErrors                            default: null
-- → deno.unstable                                                   default: false
