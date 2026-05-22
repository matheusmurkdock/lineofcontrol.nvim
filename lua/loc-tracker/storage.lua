local M = {}
local config = require("loc-tracker.config")

local function get_today_str()
    return os.date("%Y-%m-%d")
end

function M.read_data()
    local path = config.options.data_file
    local file = io.open(path, "r")
    if not file then return {} end
    
    local content = file:read("*a")
    file:close()
    
    if content == "" then return {} end
    
    local ok, data = pcall(vim.json.decode, content)
    if not ok then
        vim.notify("[loc-tracker] Error reading data file", vim.log.levels.ERROR)
        return {}
    end
    return data
end

function M.write_data(data)
    local path = config.options.data_file
    -- Create directory if it doesn't exist just in case (though stdpath("data") usually exists)
    local dir = vim.fn.fnamemodify(path, ":p:h")
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end

    local file = io.open(path, "w")
    if not file then
        vim.notify("[loc-tracker] Cannot open data file for writing: " .. path, vim.log.levels.ERROR)
        return
    end
    
    local ok, json = pcall(vim.json.encode, data)
    if not ok then
        vim.notify("[loc-tracker] Error encoding data to JSON", vim.log.levels.ERROR)
        file:close()
        return
    end
    
    file:write(json)
    file:close()
end

function M.get_today_stats()
    local data = M.read_data()
    local today = get_today_str()
    
    if not data[today] then
        data[today] = { added = 0, deleted = 0, goal = config.options.daily_goal }
        M.write_data(data)
    end
    
    return data[today]
end

function M.update_today(added, deleted)
    local data = M.read_data()
    local today = get_today_str()
    
    if not data[today] then
        data[today] = { added = 0, deleted = 0, goal = config.options.daily_goal }
    end
    
    data[today].added = data[today].added + (added or 0)
    data[today].deleted = data[today].deleted + (deleted or 0)
    
    M.write_data(data)
end

function M.set_goal(new_goal)
    local data = M.read_data()
    local today = get_today_str()
    
    if not data[today] then
        data[today] = { added = 0, deleted = 0, goal = new_goal }
    else
        data[today].goal = new_goal
    end
    
    M.write_data(data)
end

return M
