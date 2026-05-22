# 📈 loc-tracker.nvim
A lightweight Neovim plugin that tracks your lines of code (LOC) written each day and helps you achieve your daily coding goals. It operates entirely locally and uses Neovim's native buffer events to accurately record line additions and deletions in real-time.

## ✨ Features
- Tracks **net lines added** and **lines deleted** daily.
- Set a **daily LOC goal** and get a notification when you achieve it!
- Saves data locally to your Neovim data directory in a simple JSON format.
- Exposes a `statusline` function to easily display progress in `lualine.nvim` or any other statusline plugin.
- Ignores non-code buffers like terminal, NvimTree, Telescope, etc.

## Installation

Install with your favorite package manager.

**[lazy.nvim](https://github.com/folke/lazy.nvim):**
```lua
{
    "matheusmurkdock/loc-tracker.nvim",
    config = function()
        require("loc-tracker").setup({
            daily_goal = 100, -- Set your daily goal (default is 100)
        })
    end,
}
```

**[packer.nvim](https://github.com/wbthomason/packer.nvim):**
```lua
use {
    "matheusmurkdock/loc-tracker.nvim",
    config = function()
        require("loc-tracker").setup()
    end
}
```

## Configuration

The `setup` function accepts an optional table for configuration. Here are the defaults:

```lua
require('loc-tracker').setup({
    daily_goal = 100,
    -- Path to save the JSON file (defaults to ~/.local/share/nvim/loc-tracker.json)
    data_file = vim.fn.stdpath("data") .. "/loc-tracker.json",
    -- Filetypes to ignore when tracking lines
    ignore_filetypes = {
        "NvimTree",
        "TelescopePrompt",
        "nofile",
        "terminal",
        "help",
        "lazy",
        "mason",
        "netrw"
    },
})
```

## Usage

### Commands
- `:LocStatus` - Shows your current progress for today.
- `:LocGoal <number>` - Temporarily updates your goal for the day (e.g., `:LocGoal 200`).
- `:LocHeatmap` - Opens a beautiful GitHub-style floating window showing your coding activity over the past 25 weeks!

### Statusline Integration

You can easily integrate `loc-tracker` into your status line.

**For `lualine.nvim`:**
```lua
require('lualine').setup {
  sections = {
    lualine_c = {
      function()
        return require("loc-tracker").statusline()
      end,
    }
  }
}
```

##  Highlighting (Heatmap)
By default, the heatmap uses standard GitHub dark mode colors. If you want to customize them to match your theme, simply override these highlight groups in your config:
```lua
vim.api.nvim_set_hl(0, "LocTrackerLevel0", { fg = "#2d333b" }) -- Empty
vim.api.nvim_set_hl(0, "LocTrackerLevel1", { fg = "#0e4429" }) -- Low
vim.api.nvim_set_hl(0, "LocTrackerLevel2", { fg = "#006d32" }) -- Medium
vim.api.nvim_set_hl(0, "LocTrackerLevel3", { fg = "#26a641" }) -- High
vim.api.nvim_set_hl(0, "LocTrackerLevel4", { fg = "#39d353" }) -- Very High
```

## Data Storage
Data is saved locally as JSON. By default, it lives at `~/.local/share/nvim/loc-tracker.json`.
The schema looks like this:
```json
{
  "2023-10-25": { "added": 45, "deleted": 10, "goal": 100 },
  "2023-10-26": { "added": 120, "deleted": 30, "goal": 100 }
}
```

## Contributing
Pull requests are welcome! Feel free to open issues for bugs or feature requests.
