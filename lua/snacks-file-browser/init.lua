local Picker = require('snacks.picker')
local config = require('snacks-file-browser.config')
local util = require('snacks-file-browser.util')

local M = {}

---@type snacks.picker.file_browser.Config
local defaults
local function get_defaults()
  defaults = vim.tbl_deep_extend('force', config.fb_source, Picker.config.get().sources[config.fb_source.source] or {})
end

---Open file_browser picker
---@param opts? snacks.picker.file_browser.Config
function M.browse(opts)
  if not defaults then
    get_defaults()
  end
  opts = vim.tbl_deep_extend('force', defaults, opts or {})

  opts.cmd = 'fd'
  opts.args = config.fd_args(opts)

  if opts.prompt_prefix then
    opts.prompt = util.get_prompt_prefix(opts.cwd and vim.uv.fs_realpath(opts.cwd))
  end

  Picker.pick(opts)
end

---Generate cmd string for fd
---@param opts {args:table,exclude:table}
---@return string
local function get_cmd(opts)
  local args = opts.args and opts.args or {}
  for _, e in ipairs(opts.exclude or {}) do
    vim.list_extend(args, { '-E', e })
  end
  return table.concat(args, ' ')
end

local function get_directories(cmd)
  local directories = {}

  local handle = io.popen(cmd)
  if handle then
    for line in handle:lines() do
      table.insert(directories, line)
    end
    handle:close()
  else
    Snacks.notify.warn('Failed to execute fd command')
  end

  return directories
end

M.select_dir = function()
  if not defaults then
    get_defaults()
  end

  return Picker.pick({
    title = 'Select dir to browse',
    layout = defaults.layout,
    finder = function(opts, ctx)
      local dirs = get_directories(get_cmd({
        args = { 'fd', '--type', 'directory', '--type', 'symlink', '--color', 'never', '-E', '.git' },
        exclude = opts.exclude or {},
      }))

      local items = {}
      for i, item in ipairs(dirs) do
        table.insert(items, { idx = i, file = item, dir = item, text = item })
      end
      return items
    end,
    confirm = function(picker, item)
      vim.defer_fn(function()
        picker:close()
      end, 400)
      M.browse({ cwd = item.file, show_empty = true })
    end,
  })
end

return M
