local M = {}
local config = require("loc-tracker.config")
local tracker = require("loc-tracker.tracker")
local storage = require("loc-tracker.storage")

function M.setup(opts)
    config.setup(opts)
    
    -- Setup autocommands to attach to new buffers
    local group = vim.api.nvim_create_augroup("LocTracker", { clear = true })
    
    -- Attach to existing buffers on startup (if lazy loaded)
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            tracker.attach(bufnr)
        end
    end
    
    -- Attach to new buffers
    vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        callback = function(args)
            tracker.attach(args.buf)
        end
    })
    
    -- Flush data to disk on certain events
    vim.api.nvim_create_autocmd({ "VimLeavePre", "BufWritePost", "FocusLost" }, {
        group = group,
        callback = function()
            tracker.flush()
        end
    })
end

function M.statusline()
    local stats = tracker.get_status()
    local percentage = math.floor((stats.added / stats.goal) * 100)
    return string.format("LOC: %d/%d (%d%%)", stats.added, stats.goal, percentage)
end

function M.set_goal(goal)
    if type(goal) ~= "number" then
        vim.notify("[loc-tracker] Goal must be a number", vim.log.levels.ERROR)
        return
    end
    storage.set_goal(goal)
    vim.notify(string.format("[loc-tracker] Daily goal set to %d lines", goal), vim.log.levels.INFO)
end

function M.show_status()
    local stats = tracker.get_status()
    local msg = string.format("Today's LOC: %d added, %d deleted. Goal: %d", stats.added, stats.deleted, stats.goal)
    vim.notify(msg, vim.log.levels.INFO)
end

return M
