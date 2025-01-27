local config = require('snacks-file-browser.config')

---@class snacks.file_browser
---@field browse fun(opts?: snacks.picker.file_browser.Config)
local M = {}

function M.browse(opts)
  opts = vim.tbl_deep_extend('force', config.defaut_opts, opts or {})

  opts.cmd = 'fd'
  opts.args = config.fd_args(opts)

  Snacks.picker.files(opts)
end

return M
