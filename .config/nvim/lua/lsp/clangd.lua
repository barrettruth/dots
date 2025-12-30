local config = require('config.projects')

local clangd_settings = {
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
    cmd = {
        'clangd',
        '--clang-tidy',
        '-j=4',
        '--background-index',
        '--completion-style=bundled',
        '--header-insertion=iwyu',
        '--header-insertion-decorators=false',
    },
    capabilities = {
        textDocument = {
            completion = {
                editsNearCursor = true,
            },
        },
        offsetEncoding = { 'utf-8', 'utf-16' },
    },
    ---@param init_result ClangdInitializeResult
    on_init = function(client, init_result)
        if init_result.offsetEncoding then
            client.offset_encoding = init_result.offsetEncoding
        end
    end,
    root_markers = {
        '.clangd',
        '.clang-tidy',
        '.clang-format',
        'compile_commands.json',
        'compile_flags.txt',
        'configure.ac',
        '.git',
    },
}

local project_settings = (config.lsp and config.lsp.clangd)
    and config.lsp.clangd

require('config.utils').au('LspAttach', 'ClangdKeymap', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == 'clangd' then
            bmap(
                { 'n', 'gh', vim.cmd.ClangdSwitchSourceHeader },
                { buffer = args.buf }
            )
        end
    end,
})

return vim.tbl_extend('force', clangd_settings, project_settings or {})
