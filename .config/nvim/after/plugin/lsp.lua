local lsp = require('config.lsp')

vim.diagnostic.config({
    signs = false,
    float = {
        format = function(diagnostic)
            return ('%s (%s)'):format(diagnostic.message, diagnostic.source)
        end,
        header = '',
        prefix = ' ',
    },
    jump = { float = true },
})

local function prepare_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = false

    local ok, blink = pcall(require, 'blink.cmp')

    return ok and blink.get_lsp_capabilities(capabilities) or capabilities
end

vim.lsp.config('*', {
    on_attach = lsp.on_attach,
    capabilities = prepare_capabilities(),
    flags = { debounce_text_changes = 0 },
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(opts)
        local client = vim.lsp.get_client_by_id(opts.data.client_id)

        if
            client
            and (
                client:supports_method('textDocument/formatting')
                or client:supports_method('formatting')
            )
        then
            local modes = { 'n' }

            if
                client:supports_method('textDocument/rangeFormatting')
                or client:supports_method('rangeFormatting')
            then
                table.insert(modes, 'x')
            end

            bmap({
                modes,
                'gF',
                lsp.format,
            }, { buffer = opts.buf, silent = false })
        end
    end,
    group = vim.api.nvim_create_augroup('ALspFormat', { clear = true }),
})

for _, server in ipairs({
    'bashls',
    'basedpyright',
    'clangd',
    'cssls',
    'emmet_language_server',
    'eslint',
    'html',
    'mdx_analyzer',
    'jsonls',
    'vtsls',
    'pytest_lsp',
    'lua_ls',
    'ruff',
    'tinymist',
}) do
    local ok, config = pcall(require, 'lsp.' .. server)
    if ok and config then
        vim.lsp.config(server, config)
    else
        vim.lsp.config(server, {})
    end
    vim.lsp.enable(server)
end

-- remove duplicate entries from goto defintion list
-- example: https://github.com/LuaLS/lua-language-server/issues/2451
local locations_to_items = vim.lsp.util.locations_to_items
vim.lsp.util.locations_to_items = function(locations, offset_encoding)
    local lines = {}
    local loc_i = 1
    for _, loc in ipairs(vim.deepcopy(locations)) do
        local uri = loc.uri or loc.targetUri
        local range = loc.range or loc.targetSelectionRange
        if lines[uri .. range.start.line] then
            table.remove(locations, loc_i)
        else
            loc_i = loc_i + 1
        end
        lines[uri .. range.start.line] = true
    end

    return locations_to_items(locations, offset_encoding)
end
