return {
    on_attach = function(_, bufnr)
        require('lsp').on_attach(_, bufnr)
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if string.match(bufname, '%.env') then
            vim.diagnostic.enable(false, { bufnr = bufnr })
        end
    end,
    filetypes = { 'bash', 'sh', 'zsh' },
    settings = {
        bashIde = {
            globPattern = '*@(.sh|.inc|.bash|.command)',
        },
    },
}
