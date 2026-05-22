local M = {}
local config = require("loc-tracker.config")
local storage = require("loc-tracker.storage")

local attached_buffers = {}
local in_memory_added = 0
local in_memory_deleted = 0
local last_save_time = os.time()
local goal_notified = false

-- Debounced save function to avoid hitting the disk on every single keystroke
local function flush_to_disk()
    if in_memory_added == 0 and in_memory_deleted == 0 then return end
    
    storage.update_today(in_memory_added, in_memory_deleted)
    
    -- Check for goal achievement
    local stats = storage.get_today_stats()
    if stats.added >= stats.goal and not goal_notified then
        vim.notify("🎉 Congratulations! You reached your daily LOC goal of " .. stats.goal .. " lines!", vim.log.levels.INFO)
        goal_notified = true
    end

    in_memory_added = 0
    in_memory_deleted = 0
    last_save_time = os.time()
end

function M.flush()
    flush_to_disk()
end

local function on_lines(_, bufnr, _, firstline, lastline, new_lastline)
    -- Calculate net change in lines
    local old_lines = lastline - firstline
    local new_lines = new_lastline - firstline
    local diff = new_lines - old_lines
    
    if diff > 0 then
        in_memory_added = in_memory_added + diff
    elseif diff < 0 then
        in_memory_deleted = in_memory_deleted + math.abs(diff)
    end
    
    -- Flush if 60 seconds have passed since last flush
    if os.time() - last_save_time > 60 then
        flush_to_disk()
    end
end

function M.attach(bufnr)
    if attached_buffers[bufnr] then return end
    
    -- Ignore unmodifiable buffers
    if not vim.bo[bufnr].modifiable then return end

    local ft = vim.bo[bufnr].filetype
    local bt = vim.bo[bufnr].buftype
    
    -- Ignore specific filetypes and buftypes (like terminal, prompt)
    if vim.tbl_contains(config.options.ignore_filetypes, ft) or bt ~= "" then
        return
    end
    
    -- Attach to buffer
    local ok = vim.api.nvim_buf_attach(bufnr, false, {
        on_lines = on_lines,
        on_detach = function()
            attached_buffers[bufnr] = nil
        end
    })
    
    if ok then
        attached_buffers[bufnr] = true
    end
end

-- Exposed for UI and Statusline
function M.get_status()
    -- Force flush to get the most accurate current state in UI
    flush_to_disk()
    local stats = storage.get_today_stats()
    return stats
end

return M
