local M = {}

M.intelephense = {

  intelephense = {
    files = {
      maxSize = 1000000,
    },
    environment = {
      includePaths = {
        "./",
      }
    }
  }
}

return M
