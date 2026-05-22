local M = {}
local storage = require("loc-tracker.storage")
local config = require("loc-tracker.config")

local function setup_highlights()
    -- GitHub dark mode contribution colors
    vim.api.nvim_set_hl(0, "LocTrackerLevel0", { fg = "#2d333b", default = true }) -- empty day
    vim.api.nvim_set_hl(0, "LocTrackerLevel1", { fg = "#0e4429", default = true }) -- low
    vim.api.nvim_set_hl(0, "LocTrackerLevel2", { fg = "#006d32", default = true }) -- medium
    vim.api.nvim_set_hl(0, "LocTrackerLevel3", { fg = "#26a641", default = true }) -- high
    vim.api.nvim_set_hl(0, "LocTrackerLevel4", { fg = "#39d353", default = true }) -- very high
end

local function get_level(added, goal)
    if added == 0 then return 0 end
    local ratio = added / goal
    if ratio < 0.25 then return 1 end
    if ratio < 0.50 then return 2 end
    if ratio < 0.75 then return 3 end
    return 4
end

function M.show_heatmap()
    setup_highlights()
    local data = storage.read_data()
    
    local num_weeks = 25
    local now = os.time()
    local today_wday = tonumber(os.date("%w", now)) + 1 -- os.date("%w") is 0-6 (Sun-Sat), +1 makes it 1-7
    
    -- Total days to render so it aligns correctly ending on today's weekday
    local total_days = ((num_weeks - 1) * 7) + today_wday
    
    local grid = {}
    for i = 1, 7 do grid[i] = {} end
    
    local history = {}
    -- Go back in time
    for i = total_days - 1, 0, -1 do
        local d_time = now - (i * 24 * 60 * 60)
        local date_str = os.date("%Y-%m-%d", d_time)
        local wday = tonumber(os.date("%w", d_time)) + 1
        
        local stats = data[date_str] or { added = 0 }
        local goal = stats.goal or config.options.daily_goal
        local added = stats.added or 0
        local level = get_level(added, goal)
        
        table.insert(history, { date = date_str, level = level, wday = wday })
    end
    
    -- Map chronological history to a 7xW grid
    local col = 1
    for _, entry in ipairs(history) do
        grid[entry.wday][col] = entry.level
        if entry.wday == 7 then col = col + 1 end
    end
    
    local lines = {}
    local highlights = {} -- list of {line_idx, start_col, end_col, hl_group}
    
    local week_labels = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
    
    -- Build heatmap rows
    for row = 1, 7 do
        local line_str = week_labels[row] .. " "
        local row_hls = {}
        
        for c = 1, num_weeks do
            local lvl = grid[row][c]
            if lvl then
                -- '■' is 3 bytes long in UTF-8
                local start_col = #line_str
                line_str = line_str .. "■ "
                table.insert(row_hls, {
                    hl = "LocTrackerLevel" .. lvl,
                    start_col = start_col,
                    end_col = start_col + 3 
                })
            else
                line_str = line_str .. "  "
            end
        end
        table.insert(lines, line_str)
        table.insert(highlights, row_hls)
    end
    
    -- Layout padding
    table.insert(lines, 1, "   Your LOC Heatmap (Last " .. num_weeks .. " weeks)")
    table.insert(lines, 2, "")
    table.insert(lines, "")
    table.insert(lines, "   Less ■ ■ ■ ■ ■ More")
    
    -- Highlights for the legend
    local legend_hls = {
        { hl = "LocTrackerLevel0", col = 8 },
        { hl = "LocTrackerLevel1", col = 11 },
        { hl = "LocTrackerLevel2", col = 14 },
        { hl = "LocTrackerLevel3", col = 17 },
        { hl = "LocTrackerLevel4", col = 20 }
    }
    
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    local ns = vim.api.nvim_create_namespace("LocTrackerHeatmap")
    
    -- Apply grid highlights
    for i, row_hls in ipairs(highlights) do
        local line_idx = i + 1 -- offset for 2 header lines
        for _, hl in ipairs(row_hls) do
            vim.api.nvim_buf_add_highlight(buf, ns, hl.hl, line_idx, hl.start_col, hl.end_col)
        end
    end
    
    -- Apply legend highlights
    local legend_line = #lines - 1
    for _, l_hl in ipairs(legend_hls) do
        vim.api.nvim_buf_add_highlight(buf, ns, l_hl.hl, legend_line, l_hl.col, l_hl.col + 3)
    end
    
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    vim.api.nvim_set_option_value("filetype", "loc-heatmap", { buf = buf })
    
    -- Calculate window size
    local width = #lines[3] + 4 -- Max width of grid line
    local height = #lines + 1
    local ui = vim.api.nvim_list_uis()[1]
    
    -- Fallback size if ui info is weird
    local screen_w = ui and ui.width or 80
    local screen_h = ui and ui.height or 24
    
    local opts = {
        relative = "editor",
        width = width,
        height = height,
        col = (screen_w - width) / 2,
        row = (screen_h - height) / 2,
        style = "minimal",
        border = "rounded",
        title = " loc-tracker ",
        title_pos = "center"
    }
    
    local win = vim.api.nvim_open_win(buf, true, opts)
    
    -- Close keymaps
    vim.keymap.set("n", "q", ":close<CR>", { buffer = buf, silent = true })
    vim.keymap.set("n", "<Esc>", ":close<CR>", { buffer = buf, silent = true })
end

return M
