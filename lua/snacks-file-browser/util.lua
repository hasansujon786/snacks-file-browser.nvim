local M = {}

local truncate_prefix = '…'
local path_max_lenght = 40 -- Maximum allowed length

local function truncate_path(prefix, path, count)
  if #path <= count then
    return path -- No need to truncate if already within the limit
  end
  local truncated = prefix .. path:sub(#path - count + #prefix + 1)
  return truncated
end

local function path_shorten_with_last(path, max_length)
  if #path <= max_length then
    return path
  end

  local parts = vim.split(path, '/', { plain = true })
  if #parts > 1 then
    local last_part = table.remove(parts) -- Remove and store the last directory
    local shortened = vim.fn.pathshorten(table.concat(parts, '/'))
    return shortened .. '/' .. last_part -- Reattach the last directory
  else
    return path
  end
end

local function ensure_trailing_slash(path)
  local sep = '/'
  if not path:match(sep .. '$') then
    path = path .. sep
  end
  return path
end

function M.make_path_relative(base, path)
  if path:sub(1, #base) == base then
    -- +2 to remove the leading slash/backslash
    return path:sub(#base + 2), true
  end
  return path, false
end

function M.get_prompt_prefix(picker_cwd)
  local cwd = vim.fs.normalize(vim.uv.cwd())
  picker_cwd = vim.fs.normalize(picker_cwd)
  local path, is_relative = M.make_path_relative(cwd, picker_cwd)

  local prefix
  if is_relative then
    prefix = './' .. path_shorten_with_last(path, path_max_lenght)
  else
    prefix = path_shorten_with_last(path, path_max_lenght)
  end
  return ensure_trailing_slash(prefix)
end

---Replace input prompt with cwd
---@param win number
---@param picker_cwd string
M.update_prompt = function(win, picker_cwd)
  local function add(str, hl)
    if str then
      return ('%%#%s#%s%%*'):format(hl, str:gsub('%%', '%%'))
    end
  end

  local sc = add(M.get_prompt_prefix(picker_cwd), 'SnacksPickerPrompt')
  Snacks.util.wo(win, { statuscolumn = sc })
end

return M
