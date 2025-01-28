local Picker = require('snacks.picker')
local config = require('snacks-file-browser.config')
local util = require('snacks-file-browser.util')

local M = {}

---@type snacks.picker.file_browser.Config
local defaults

---Open file_browser picker
---@param opts snacks.picker.file_browser.Config
function M.browse(opts)
  if not defaults then
    defaults = vim.tbl_deep_extend('force', config.fb_source, Picker.config.get().sources['file_browser'] or {})
  end
  opts = vim.tbl_deep_extend('force', defaults, opts or {})

  opts.cmd = 'fd'
  opts.args = config.fd_args(opts)

  if opts.prompt_prefix then
    opts.prompt = util.get_prompt_prefix(vim.uv.fs_realpath(opts.cwd))
  end

  Picker.files(opts)
end

return M
