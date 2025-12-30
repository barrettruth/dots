return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        build = ':TSUpdate',
        lazy = false,
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        init = function()
            vim.api.nvim_create_autocmd('FileType', {
                pattern = '*',
                callback = function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    local lines = vim.api.nvim_buf_line_count(bufnr)

                    if lines < 5000 then
                        pcall(vim.treesitter.start)
                    else
                        vim.notify_once(
                            ('Skipping tree-sitter for bufnr %s; file too large (%s >= 5000 lines)'):format(
                                bufnr,
                                lines
                            )
                        )
                    end
                end,
            })
        end,
        keys = {
            {
                '<leader>T',
                function()
                    local lang_map = { htmldjango = 'html' }
                    local bufnr = vim.api.nvim_get_current_buf()
                    local parser = vim.treesitter.get_parser(bufnr)
                    local lang = parser:lang()
                    local path = (
                        vim.env.NVIM_APPNAME or vim.fn.stdpath('config')
                    )
                        .. ('/after/queries/%s/highlights.scm'):format(
                            lang_map[lang] or lang
                        )

                    if vim.loop.fs_stat(path) then
                        vim.fn.rename(path, path .. '.disabled')
                    elseif vim.loop.fs_stat(path .. '.disabled') then
                        vim.fn.rename(path .. '.disabled', path)
                    end
                    vim.cmd.TSBufToggle('highlight')
                    vim.cmd.TSBufToggle('highlight')
                end,
            },
        },
    },
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        build = ':TSUpdate',
        lazy = false,
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        init = function()
            vim.api.nvim_create_autocmd('FileType', {
                pattern = '*',
                callback = function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    local lines = vim.api.nvim_buf_line_count(bufnr)
                    if lines < 5000 then
                        pcall(vim.treesitter.start)
                    end
                end,
            })
        end,
        keys = {
            {
                '<leader>T',
                function()
                    local lang_map = { htmldjango = 'html' }
                    local bufnr = vim.api.nvim_get_current_buf()
                    local parser = vim.treesitter.get_parser(bufnr)
                    local lang = parser:lang()
                    local path = (
                        vim.env.NVIM_APPNAME or vim.fn.stdpath('config')
                    )
                        .. ('/after/queries/%s/highlights.scm'):format(
                            lang_map[lang] or lang
                        )
                    if vim.loop.fs_stat(path) then
                        vim.fn.rename(path, path .. '.disabled')
                    elseif vim.loop.fs_stat(path .. '.disabled') then
                        vim.fn.rename(path .. '.disabled', path)
                    end
                    vim.treesitter.stop()
                    vim.treesitter.start()
                end,
            },
        },
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        dependencies = 'nvim-treesitter/nvim-treesitter',
        init = function()
            vim.g.no_plugin_maps = true
        end,
        opts = {
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
                    aa = '@parameter.outer',
                    ia = '@parameter.inner',
                    ab = '@block.outer',
                    ib = '@block.inner',
                    as = '@class.outer',
                    is = '@class.inner',
                    aC = '@call.outer',
                    iC = '@call.inner',
                    af = '@function.outer',
                    ['if'] = '@function.inner',
                    ai = '@conditional.outer',
                    ii = '@conditional.inner',
                    aL = '@loop.outer',
                    iL = '@loop.inner',
                },
            },
            move = {
                enable = true,
                set_jumps = true,
                goto_next_start = {
                    [']a'] = '@parameter.inner',
                    [']s'] = '@class.outer',
                    [']f'] = '@function.outer',
                    [']i'] = '@conditional.outer',
                    [']/'] = '@comment.outer',
                },
                goto_next_end = {
                    [']A'] = '@parameter.inner',
                    [']F'] = '@function.outer',
                    [']I'] = '@conditional.outer',
                },
                goto_previous_start = {
                    ['[a'] = '@parameter.inner',
                    ['[s'] = '@class.outer',
                    ['[f'] = '@function.outer',
                    ['[i'] = '@conditional.outer',
                    ['[/'] = '@comment.outer',
                },
                goto_previous_end = {
                    ['[A'] = '@parameter.inner',
                    ['[F'] = '@function.outer',
                    ['[I'] = '@conditional.outer',
                },
            },
        },
    },
    {
        'Wansmer/treesj',
        config = true,
        keys = {
            { 'gt', '<cmd>lua require("treesj").toggle()<cr>' },
        },
    },
}
