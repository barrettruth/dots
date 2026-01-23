local M = {}

local Methods = vim.lsp.protocol.Methods

function M.on_attach(client, bufnr)
    if client:supports_method(Methods.textDocument_hover) then
        bmap({ 'n', 'K', vim.lsp.buf.hover })
    end

    if client:supports_method(Methods.textDocument_documentSymbol) then
        local ok, navic = pcall(require, 'nvim-navic')
        if ok then
            navic.attach(client, bufnr)
        end
    end

    local ok, _ = pcall(require, 'fzf-lua')

    local mappings = {
        {
            Methods.textDocument_codeAction,
            'gra',
            ok and '<cmd>FzfLua lsp_code_actions<CR>'
                or vim.lsp.buf.code_action,
        },
        {
            Methods.textDocument_declaration,
            'gD',
            ok and '<cmd>FzfLua lsp_declarations<CR>'
                or vim.lsp.buf.declaration,
        },
        {
            Methods.textDocument_definition,
            'gd',
            ok and '<cmd>FzfLua lsp_definitions<CR>' or vim.lsp.buf.definition,
        },
        {
            Methods.textDocument_implementation,
            'gri',
            ok and '<cmd>FzfLua lsp_implementations<CR>'
                or vim.lsp.buf.implementation,
        },
        {
            Methods.textDocument_references,
            'grr',
            ok and '<cmd>FzfLua lsp_references<CR>' or vim.lsp.buf.references,
        },
        {
            Methods.textDocument_typeDefinition,
            'grt',
            ok and '<cmd>FzfLua lsp_typedefs<CR>'
                or vim.lsp.buf.type_definition,
        },
        {
            Methods.textDocument_documentSymbol,
            'gs',
            ok and '<cmd>FzfLua lsp_document_symbols<CR>'
                or vim.lsp.buf.document_symbol,
        },
        {
            Methods.workspace_diagnostic,
            'gw',
            ok and '<cmd>FzfLua lsp_workspace_diagnostics<CR>'
                or vim.diagnostic.setqflist,
        },
        {
            Methods.workspace_symbol,
            'gS',
            ok and '<cmd>FzfLua lsp_workspace_symbols<CR>'
                or vim.lsp.buf.workspace_symbol,
        },
    }

    for _, m in ipairs(mappings) do
        local method, key, cmd = unpack(m)
        if client:supports_method(method) then
            bmap({ 'n', key, cmd })
        end
    end
end

local FORMAT_LSPS = { 'null-ls', 'clangd', 'tinymist', 'ruff' }

function M.format(opts)
    local format_opts = vim.tbl_extend('force', opts or {}, {
        filter = function(c)
            if c.name == 'typescript-tools' then
                vim.cmd.TSToolsOrganizeImports()
            end
            return vim.tbl_contains(FORMAT_LSPS, c.name)
        end,
    })
    vim.lsp.buf.format(format_opts)
    vim.cmd.w()
end

return M
