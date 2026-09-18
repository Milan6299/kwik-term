# kwik-term

A lightweight Neovim terminal plugin for quickly opening, toggling, and sending commands to a persistent terminal.

## Features

* Floating terminal
* Bottom split terminal
* Persistent terminal buffer
* Send arbitrary commands to the terminal
* Run the current file with a custom command
* Configurable terminal size and border
* Simple Lua API
* User commands for quick access

## Installation

### lazy.nvim

Using a local development copy:

```lua
{
  dir = "~/projects/kwik-term",
  name = "kwik-term",
}
```

For a GitHub repository:

```lua
{
  "Milan6299/kwik-term",
  config = function()
    require("kwik-term").setup()
  end,
}
```

## Usage

### User Commands

Open a floating terminal:

```vim
:KwikTermFloat
```

Open a bottom split terminal:

```vim
:KwikTermSplit
```

Send a command to the terminal:

```vim
:KwikTermSend git status
```

Any shell command can be passed to `KwikTermSend`.

Examples:

```vim
:KwikTermSend ls -la
:KwikTermSend git status
:KwikTermSend uv run main.py
:KwikTermSend npm run dev
```

## Lua API

You can also use `kwik-term` directly from Lua:

```lua
local kwik = require("kwik-term")

kwik.open()
kwik.open({ float = true })

kwik.toggle()
kwik.toggle({ float = true })

kwik.send("git status")

kwik.run_current_file("uv run")
```

## Configuration

```lua
require("kwik-term").setup({
  height = 7,
  width = 0.9,
  height_ratio = 0.9,
  border = "single",
  start_in_insert = true,
})
```

### Options

| Option            |    Default | Description                           |
| ----------------- | ---------: | ------------------------------------- |
| `height`          |        `7` | Height of the split terminal          |
| `width`           |      `0.9` | Width ratio of the floating terminal  |
| `height_ratio`    |      `0.9` | Height ratio of the floating terminal |
| `border`          | `"single"` | Floating window border                |
| `start_in_insert` |     `true` | Enter insert mode when opening        |

## Keymaps

`kwik-term` does not impose any global keymaps. Add your own:

```lua
local kwik = require("kwik-term")

vim.keymap.set("n", "<leader>tt", function()
  kwik.toggle()
end, { desc = "Toggle terminal" })

vim.keymap.set("n", "<leader>tf", function()
  kwik.toggle({ float = true })
end, { desc = "Toggle floating terminal" })

vim.keymap.set("n", "<leader>tr", function()
  kwik.run_current_file("uv run")
end, { desc = "Run current file" })
```

## Structure

```text
kwik-term/
├── lua/
│   └── kwik-term/
│       └── init.lua
└── plugin/
    └── kwik-term.lua
```

## Why?

Sometimes you just need a terminal without leaving your editor. Even though Neovim comes with a terminal command it doesn't have a pre-configured floating window or even a sane keymap (Ctrl + \ + Ctrl + n) for getting back to normal mode.

`kwik-term` provides a small API for keeping a terminal around and sending commands to it without adding a large amount of configuration or terminal-management machinery.

This is mainly designed for quick lookups, scratch terminal, running file commands like `python filename.py` thus making user workflow smooth and fast.

It is suggested to use complex long running and important tasks in a separate terminal.

## License

MIT
