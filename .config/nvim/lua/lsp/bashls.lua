return {
    on_attach = function(_, bufnr)
        require('config.lsp').on_attach(_, bufnr)
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if string.match(bufname, '%.env') then
            vim.diagnostic.enable(false, { bufnr = bufnr })
        end
    end,
}
