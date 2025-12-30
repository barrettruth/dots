local project_configs = {
    cavauto = {
        lsp = {
            clangd = {
                cmd = { 'socat', '-', 'TCP:localhost:12345' },
            },
        },
    },
}

local function project_name()
    return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
end

return project_configs[project_name()] or {}
