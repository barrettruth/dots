local M = {}
M.opts = nil

function M.setup(opts)
    M.opts = vim.deepcopy(opts)
    -- allow connections from `theme` script
    local socket_path = ('/tmp/nvim-%d.sock'):format(vim.fn.getpid())
    vim.fn.serverstart(socket_path)
end

---@disable_fzf_lua_reload boolean?
function M.reload(disable_fzf_lua_reload)
    local path = vim.fn.expand('~/.config/fzf/themes/theme')
    if vim.fn.filereadable(path) == 0 then
        return
    end
    local lines = vim.fn.readfile(path)
    if not lines or #lines == 0 then
        return
    end
    local colors = {}
    for color_spec in table.concat(lines, '\n'):gmatch('--color=([^%s]+)') do
        for k, v in color_spec:gmatch('([^:,]+):([^,]+)') do
            colors[k] = v
        end
    end
    if not M.opts then
        return
    end
    M.opts.fzf_colors = colors
    if not disable_fzf_lua_reload then
        require('fzf-lua').setup(M.opts)
    end
end

return M
