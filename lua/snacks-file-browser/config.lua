local fb_actions = require('snacks-file-browser.actions')
local util = require('snacks-file-browser.util')

local M = {}

---@type snacks.picker.file_browser.Config
M.fb_source = {
  ---@type table<string, string|false|snacks.picker.toggle>
  toggles = {
    follow = 'f',
    hidden = 'h',
    ignored = 'i',
    modified = 'm',
    regex = { icon = 'R', value = false },
  },
  title = 'File browser',
  show_empty = true,
  format = 'file',
  finder = 'files',
  source = 'file_browser',
  supports_live = false,
  layout = 'ivy',
  matcher = {
    sort_empty = true,
  },
  -- cmd = "fd",
  -- args = fd_args(opts),

  -- file_browser specific opts
  depth = 1,
  add_dirs = true,
  prompt_prefix = true,

  sort = function(a, b)
    local a_is_dir = a and a.type == 'directory'
    local b_is_dir = b and b.type == 'directory'

    -- if both are dir, "shorter" string of the two
    if a_is_dir and b_is_dir then
      return a.file < b.file
      -- prefer directories
    elseif a_is_dir and not b_is_dir then
      return true
    elseif not a_is_dir and b_is_dir then
      return false
    else
      return a.file < a.file
    end
  end,
  transform = function(item)
    local path = item.cwd .. '/' .. item.file
    local item_stat = vim.uv.fs_stat(path)

    if item_stat then
      item.type = item_stat.type
      item._path = path
      item.file = path

      if item_stat.type == 'directory' then
        item.dir = item.file
      end
    end
  end,
  confirm = function(picker, item)
    local item_path = vim.uv.fs_realpath(item.file)

    if item.type == 'file' then
      picker:close()
      vim.cmd.edit(item_path)
    elseif item.type == 'directory' then
      picker.input:set('')
      util.change_picker_cwd(item_path, picker)
    end

    -- end
  end,
  actions = fb_actions,
  win = {
    input = {
      keys = {
        ['<c-t>'] = { 'goto_parent', mode = { 'i', 'n' } },
        ['<c-u>'] = { 'clear_prompt_or_goto_cwd', mode = { 'i' } },
        ['<bs>'] = { 'backspace', mode = { 'i', 'n' } },
      },
    },
  },
}

---Generate fd cmd args
---@param opts snacks.picker.file_browser.Config
---@return table<string>
function M.fd_args(opts)
  local args = {}
  if opts.absolute then
    table.insert(args, '--absolute-path') -- '--path-separator=' .. os_sep,
  end
  if opts.add_dirs then
    table.insert(args, '--type')
    table.insert(args, 'directory')
  end
  if type(opts.depth) == 'number' then
    table.insert(args, '--maxdepth')
    table.insert(args, opts.depth)
  end

  -- if hidden_opts(opts) then
  --   table.insert(args, '--hidden')
  -- end
  if opts.respect_gitignore == false then
    table.insert(args, '--no-ignore-vcs')
  end
  if opts.no_ignore then
    table.insert(args, '--no-ignore')
  end
  if opts.follow_symlinks then
    table.insert(args, '--follow')
  end
  return args
end

---@class snacks.picker.file_browser.Config: snacks.picker.files.Config
---@field depth? number
---@field add_dirs? boolean
---@field prompt_prefix? boolean
---@field format? string
---@field finder? string
---@field supports_live? boolean

return M
