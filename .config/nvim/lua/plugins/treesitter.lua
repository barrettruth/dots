return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        build = ':TSUpdate',
        lazy = false,
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
                group = vim.api.nvim_create_augroup(
                    'ATreeSitter',
                    { clear = true }
                ),
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
            },
            move = {
                enable = true,
                set_jumps = true,
            },
        },
        config = function(_, opts)
            require('nvim-treesitter-textobjects').setup(opts)

            local select = require('nvim-treesitter-textobjects.select')
            local select_maps = {
                { 'aa', '@parameter.outer' },
                { 'ia', '@parameter.inner' },
                { 'ab', '@block.outer' },
                { 'ib', '@block.inner' },
                { 'as', '@class.outer' },
                { 'is', '@class.inner' },
                { 'aC', '@call.outer' },
                { 'iC', '@call.inner' },
                { 'af', '@function.outer' },
                { 'if', '@function.inner' },
                { 'ai', '@conditional.outer' },
                { 'ii', '@conditional.inner' },
                { 'aL', '@loop.outer' },
                { 'iL', '@loop.inner' },
            }
            for _, m in ipairs({ 'x', 'o' }) do
                for _, t in ipairs(select_maps) do
                    map({
                        m,
                        t[1],
                        function()
                            select.select_textobject(t[2], 'textobjects', m)
                        end,
                    })
                end
            end

            local move = require('nvim-treesitter-textobjects.move')
            local move_maps = {
                { ']a', 'goto_next_start', '@parameter.inner' },
                { ']s', 'goto_next_start', '@class.outer' },
                { ']f', 'goto_next_start', '@function.outer' },
                { ']i', 'goto_next_start', '@conditional.outer' },
                { ']/', 'goto_next_start', '@comment.outer' },
                { ']A', 'goto_next_end', '@parameter.inner' },
                { ']F', 'goto_next_end', '@function.outer' },
                { ']I', 'goto_next_end', '@conditional.outer' },
                { '[a', 'goto_previous_start', '@parameter.inner' },
                { '[s', 'goto_previous_start', '@class.outer' },
                { '[f', 'goto_previous_start', '@function.outer' },
                { '[i', 'goto_previous_start', '@conditional.outer' },
                { '[/', 'goto_previous_start', '@comment.outer' },
                { '[A', 'goto_previous_end', '@parameter.inner' },
                { '[F', 'goto_previous_end', '@function.outer' },
                { '[I', 'goto_previous_end', '@conditional.outer' },
            }
            for _, m in ipairs({ 'n', 'x', 'o' }) do
                for _, t in ipairs(move_maps) do
                    map({
                        m,
                        t[1],
                        function()
                            move[t[2]](t[3], 'textobjects')
                        end,
                    })
                end
            end

            local ts_repeat =
                require('nvim-treesitter-textobjects.repeatable_move')
            for _, m in ipairs({ 'n', 'x', 'o' }) do
                map({ m, ';', ts_repeat.repeat_last_move_next })
                map({ m, ',', ts_repeat.repeat_last_move_previous })
                map({ m, 'f', ts_repeat.builtin_f_expr }, { expr = true })
                map({ m, 'F', ts_repeat.builtin_F_expr }, { expr = true })
                map({ m, 't', ts_repeat.builtin_t_expr }, { expr = true })
                map({ m, 'T', ts_repeat.builtin_T_expr }, { expr = true })
            end
        end,
    },
    {
        'Wansmer/treesj',
        config = true,
        keys = {
            { 'gt', '<cmd>lua require("treesj").toggle()<cr>' },
        },
    },
}
