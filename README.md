# 📂 `snacks-file-browser.nvim`

`snacks-file-browser.nvim` is a file browser picker for `snacks.nvim`.
This project was created as an alternative to `telescope-file-browser` to fill the void I felt after switching to `snacks.nvim`.

> [!important]
> The plugin is a work in progress (WIP).

## ⚡️ Requirements

- [snacks.nvim][https://github.com/folke/snacks.nvim]
- [fd](https://github.com/sharkdp/fd) _(for faster browser)_

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "folke/snacks.nvim",
    dependencies = { 'hasansujon786/snacks-file-browser.nvim' }
}
```

## 📚 Usage

```lua
require('snacks-file-browser').browse(opts)

-- Or show cwd
require('snacks-file-browser').browse({ cwd = vim.fn.expand('%:h') })
```

## 📚 Setup

```lua
-- lazy.nvim
{
    "folke/snacks.nvim",
    dependencies = { 'hasansujon786/snacks-file-browser.nvim' }
    keys = {
        { '<leader>.', function() require('snacks-file-browser').browse({ cwd = vim.fn.expand('%:h') }) end, desc = 'Browse current directory' },
        { '<leader>fb', function() require('snacks-file-browser').browse() end, desc = 'Browser directory' },
    }
    ---@type snacks.Config
    opts = {
        picker = {
            sources = {
                ---@type snacks.picker.file_browser.Config
                file_browser = {
                    -- Put config here
                },
            }

        }
    }
}
```

<details><summary>Default Options</summary>

<!-- config:start -->

```lua
---@type snacks.picker.file_browser.Config
file_browser = {
    -- file_browser specific opts
    title = 'File browser',
    depth = 1,
    add_dirs = true,
    prompt_prefix = true,

    -- General picker opts
    format = 'file',
    finder = 'files',
    source = 'file_browser',
    supports_live = false,
    layout = 'ivy',
    matcher = {
        sort_empty = true,
    },
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
```

<!-- config:end -->

</details>

## Supported actions

| Insert / Normal | fb_actions               | Description                                                       |
| --------------- | ------------------------ | ----------------------------------------------------------------- |
| `<c-t>`         | goto_parent              | Go to parent directory                                            |
| `<bs>`          | backspace                | When input is empty, goes to parent dir. Otherwise acts normally  |
| `<c-u>`         | clear_prompt_or_goto_cwd | When input is empty, goes to root of cwd. Otherwise acts normally |

_(File manipulating actions such as delete,move in WIP)_

## Acknowledgements

The plugin design is heavily inspired by this excellent plugins:

- [telescope-file-browser.nvim](https://github.com/nvim-telescope/telescope-file-browser.nvim)
