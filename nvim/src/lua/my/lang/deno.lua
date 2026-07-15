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

M.get_deno_json_path = function()
  local root = require('my.utils').project_root()
  if not root then
    return nil
  end

  local deno_json_path = table.concat({ root, 'deno.json' }, '/')
  if vim.fn.filereadable(deno_json_path) == 0 then
    return nil
  end

  return deno_json_path
end

M.has_deno_json = function()
  return M.get_deno_json_path() ~= nil
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
