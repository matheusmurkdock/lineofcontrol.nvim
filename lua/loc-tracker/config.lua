local M = {}

M.defaults = {
    daily_goal = 100,
    data_file = vim.fn.stdpath("data") .. "/loc-tracker.json",
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
}

M.options = {}

function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
