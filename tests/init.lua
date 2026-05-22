-- To run tests manually, run from the root of the project:
-- nvim -u tests/init.lua

-- Add the current directory to Neovim's runtime path so it can load our plugin
local root = vim.fn.fnamemodify(vim.fn.expand("<sfile>"), ":p:h:h")
vim.opt.rtp:append(root)

-- Set up the plugin
require("loc-tracker").setup({
    daily_goal = 50, -- Set lower goal for testing
})

-- Show statusline in our minimal test environment
vim.opt.laststatus = 2
vim.opt.statusline = "%f %h%m%r %= %{luaeval('require(\"loc-tracker\").statusline()')} "

vim.notify("loc-tracker loaded! Try adding some lines, then run :LocStatus", vim.log.levels.INFO)
