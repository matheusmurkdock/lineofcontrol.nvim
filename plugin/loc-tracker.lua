if vim.g.loaded_loc_tracker then
    return
end
vim.g.loaded_loc_tracker = true

local loc = require("loc-tracker")

vim.api.nvim_create_user_command("LocStatus", function()
    loc.show_status()
end, { desc = "Show current LOC tracking status" })

vim.api.nvim_create_user_command("LocGoal", function(opts)
    local goal = tonumber(opts.args)
    if not goal then
        vim.notify("[loc-tracker] Please provide a valid number. Usage: :LocGoal <number>", vim.log.levels.ERROR)
        return
    end
    loc.set_goal(goal)
end, { nargs = 1, desc = "Set daily LOC goal" })
