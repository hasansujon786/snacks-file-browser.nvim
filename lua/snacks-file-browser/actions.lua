local update_statuscolumn = function(win, cwd)
  local function add(str, hl)
    if str then
      return ('%%#%s#%s%%*'):format(hl, str:gsub('%%', '%%'))
    end
  end

  local sc = add(cwd .. '/', 'SnacksPickerPrompt')
  Snacks.util.wo(win, { statuscolumn = sc })
end

----@class snacks.picker.actions
---@type table<string, snacks.picker.Action.spec> actions used by keymaps
local actions = {
  backspace = function(picker)
    local prompt_text = picker.input:get()
    if #prompt_text == 0 then
      picker:action('goto_parent')
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<bs>', true, false, true), 'tn', false)
    end
  end,
  goto_parent = function(picker, _)
    local cwd = vim.loop.fs_realpath(picker:cwd())
    if not cwd or cwd == '' then
      return
    end
    local new_cwd = vim.fn.fnamemodify(cwd, ':h')
    if new_cwd == cwd then
      dd('no root')
      return
    end

    picker:set_cwd(new_cwd)
    picker.input:set('')
    -- update_statuscolumn(picker.input.win.win, picker:cwd())

    picker:find({ refresh = true })
  end,
  clear_prompt_or_goto_cwd = function(picker)
    local prompt_text = picker.input:get()

    if #prompt_text == 0 then
      local cwd = vim.uv.cwd()
      if not cwd then
        return
      end
      cwd = vim.fs.normalize(cwd, { _fast = true, expand_env = false })

      if picker:cwd() == cwd then
        return
      end

      picker:set_cwd(cwd)
      picker:find({ refresh = true })
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-u>', true, false, true), 'tn', false)
    end
  end,
  -- cd = function(picker, selected)
  --   cwd = vim.loop.fs_realpath(cwd .. '/' .. selected.file)
  --   vim.cmd('tcd ' .. cwd)
  --   picker:find()
  -- end,
}

return actions
