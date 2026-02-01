return {
    {
        'barrettruth/live-server.nvim',
        build = 'pnpm add -g live-server',
        cmd = { 'LiveServerStart', 'LiveServerStart' },
        config = true,
        keys = { { '<leader>L', '<cmd>LiveServerToggle<cr>' } },
    },
    {
        'echasnovski/mini.pairs',
        config = true,
        event = 'InsertEnter',
    },
    {
        'iamcco/markdown-preview.nvim',
        build = 'pnpm up && cd app && pnpm install',
        ft = { 'markdown' },
        config = function()
            vim.cmd([[
                function OpenMarkdownPreview(url)
                    exec "silent !$BROWSER -n --args " . a:url
                endfunction
            ]])
            vim.g.mkdp_auto_close = 0
            vim.g.mkdp_browserfunc = 'OpenMarkdownPreview'
            vim.api.nvim_create_autocmd('FileType', {
                pattern = 'markdown',
                callback = function(opts)
                    bmap(
                        { 'n', '<leader>m', vim.cmd.MarkdownPreviewToggle },
                        { buffer = opts.buf }
                    )
                end,
                group = vim.api.nvim_create_augroup(
                    'AMarkdownKeybind',
                    { clear = true }
                ),
            })
        end,
    },
    {
        'lervag/vimtex',
        init = function()
            vim.g.vimtex_view_method = 'general'
            vim.g.vimtex_compiler_method = 'latexmk'
            vim.g.vimtex_callback_progpath = '/usr/bin/nvim'
            vim.g.vimtex_quickfix_mode = 0
        end,
        ft = { 'plaintext', 'tex' },
    },
    {
        'L3MON4D3/LuaSnip',
        build = 'make install_jsregexp',
        config = function()
            local ls = require('luasnip')

            ls.filetype_extend('htmldjango', { 'html' })
            ls.filetype_extend('markdown', { 'html' })
            ls.filetype_extend('javascriptreact', { 'javascript', 'html' })
            ls.filetype_extend('typescript', { 'javascript' })
            ls.filetype_extend(
                'typescriptreact',
                { 'javascriptreact', 'javascript', 'html' }
            )

            require('luasnip.loaders.from_lua').lazy_load()
        end,
        keys = {
            -- restore digraph mapping
            { '<c-d>', '<c-k>', mode = 'i' },
            {
                '<c-space>',
                '<cmd>lua require("luasnip").expand()<cr>',
                mode = 'i',
            },
            {
                '<c-h>',
                '<cmd>lua if require("luasnip").jumpable(-1) then require("luasnip").jump(-1) end<cr>',
                mode = { 'i', 's' },
            },
            {
                '<c-l>',
                '<cmd>lua if require("luasnip").jumpable(1) then require("luasnip").jump(1) end<cr>',
                mode = { 'i', 's' },
            },
            {
                '<c-j>',
                '<cmd>lua if require("luasnip").choice_active() then require("luasnip").change_choice(-1) end<cr>',
                mode = 'i',
            },
            {
                '<c-k>',
                '<cmd>lua if require("luasnip").choice_active() then require("luasnip").change_choice(1) end<cr>',
                mode = 'i',
            },
        },
        opts = {
            region_check_events = 'InsertEnter',
            delete_check_events = {
                'TextChanged',
                'TextChangedI',
                'InsertLeave',
            },
            ext_opts = {
                [require('luasnip.util.types').choiceNode] = {
                    active = {
                        virt_text = {
                            {
                                ' <- ',
                                vim.wo.cursorline and 'CursorLine' or 'Normal',
                            },
                        },
                    },
                },
            },
        },
    },
    {
        'laytan/cloak.nvim',
        config = true,
        keys = { { '<leader>Ct', '<cmd>CloakToggle<cr>' } },
        event = 'BufReadPre .env*',
    },
    {
        'maxmellon/vim-jsx-pretty',
        ft = {
            'javascript',
            'javascriptreact',
            'typescript',
            'typescriptreact',
        },
    },
    {
        'monaqa/dial.nvim',
        config = function(_)
            local augend = require('dial.augend')
            require('dial.config').augends:register_group({
                default = {
                    augend.integer.alias.decimal_int,
                    augend.integer.alias.hex,
                    augend.integer.alias.octal,
                    augend.integer.alias.binary,
                    augend.constant.alias.bool,
                    augend.constant.alias.alpha,
                    augend.constant.alias.Alpha,
                    augend.semver.alias.semver,
                },
            })
        end,
        keys = {
            {
                '<c-a>',
                function()
                    require('dial.map').manipulate('increment', 'normal')
                end,
                mode = 'n',
            },
            {
                '<c-x>',
                function()
                    require('dial.map').manipulate('decrement', 'normal')
                end,
                mode = 'n',
            },
            {
                'g<c-a>',
                function()
                    require('dial.map').manipulate('increment', 'gnormal')
                end,
                mode = 'n',
            },
            {
                'g<c-x>',
                function()
                    require('dial.map').manipulate('decrement', 'gnormal')
                end,
                mode = 'n',
            },

            {
                '<c-a>',
                function()
                    require('dial.map').manipulate('increment', 'visual')
                end,
                mode = 'v',
            },
            {
                '<c-x>',
                function()
                    require('dial.map').manipulate('decrement', 'visual')
                end,
                mode = 'v',
            },
            {
                'g<c-a>',
                function()
                    require('dial.map').manipulate('increment', 'gvisual')
                end,
                mode = 'v',
            },
            {
                'g<c-x>',
                function()
                    require('dial.map').manipulate('decrement', 'gvisual')
                end,
                mode = 'v',
            },
        },
    },
    {
        'cbochs/grapple.nvim',
        opts = {
            scope = 'git_branch',
            icons = false,
            status = false,
            win_opts = {
                title = '',
                footer = '',
            },
        },
        keys = {
            { '<leader>ha', '<cmd>Grapple toggle<cr>' },
            { '<leader>hd', '<cmd>Grapple untag<cr>' },
            { '<leader>hq', '<cmd>Grapple toggle_tags<cr>' },

            { '<c-1>', '<cmd>Grapple select index=1<cr>' },
            { '<c-2>', '<cmd>Grapple select index=2<cr>' },
            { '<c-3>', '<cmd>Grapple select index=3<cr>' },
            { '<c-4>', '<cmd>Grapple select index=4<cr>' },

            { ']h', '<cmd>Grapple cycle_tags next<cr>' },
            { '[h', '<cmd>Grapple cycle_tags prev<cr>' },
        },
    },
    {
        'catgoose/nvim-colorizer.lua',
        opts = {
            user_default_options = {
                names = false,
                rrggbbaa = true,
                css = true,
                css_fn = true,
                rgb_fn = true,
                hsl_fn = true,
            },
        },
        event = 'VeryLazy',
    },
    {
        'stevearc/oil.nvim',
        config = function(_, opts)
            require('oil').setup(opts)
            vim.api.nvim_create_autocmd('BufEnter', {
                callback = function()
                    local ft = vim.bo.filetype
                    if ft == '' then
                        local path = vim.fn.expand('%:p')
                        if vim.fn.isdirectory(path) == 1 then
                            vim.cmd('Oil ' .. path)
                        end
                    end
                end,
                group = vim.api.nvim_create_augroup('AOil', { clear = true }),
            })
        end,
        event = 'VeryLazy',
        keys = {
            { '-', '<cmd>e .<cr>' },
            { '_', vim.cmd.Oil },
        },
        opts = {
            skip_confirm_for_simple_edits = true,
            prompt_save_on_select_new_entry = false,
            float = { border = 'single' },
            view_options = {
                is_hidden_file = function(name, bufnr)
                    local dir = require('oil').get_current_dir(bufnr)
                    if not dir then
                        return false
                    end
                    if vim.startswith(name, '.') then
                        return false
                    end
                    local git_dir = vim.fn.finddir('.git', dir .. ';')
                    if git_dir == '' then
                        return false
                    end
                    local fullpath = dir .. '/' .. name
                    local result =
                        vim.fn.systemlist({ 'git', 'check-ignore', fullpath })
                    return #result > 0
                end,
            },
            keymaps = {
                ['<C-h>'] = false,
                ['<C-t>'] = false,
                ['<C-l>'] = false,
                ['<C-r>'] = 'actions.refresh',
                ['<C-s>'] = { 'actions.select', opts = { vertical = true } },
                ['<C-x>'] = { 'actions.select', opts = { horizontal = true } },
                ['q'] = function()
                    local ok, bufremove = pcall(require, 'mini.bufremove')
                    if ok then
                        bufremove.delete()
                    else
                        vim.cmd.bd()
                    end
                end,
            },
        },
    },
    {
        'echasnovski/mini.misc',
        config = true,
        keys = {
            {
                '<c-w>m',
                "<cmd>lua MiniMisc.zoom(0, { title = '', border = 'none' })<cr>",
            },
        },
    },
    {
        'nvim-mini/mini.bufremove',
        config = true,
        keys = {
            {
                '<leader>bd',
                '<cmd>lua MiniBufremove.delete()<cr>',
            },
            {
                '<leader>bw',
                '<cmd>lua MiniBufremove.wipeout()<cr>',
            },
        },
    },
    { 'tpope/vim-abolish', event = 'VeryLazy' },
    { 'tpope/vim-sleuth', event = 'BufReadPost' },
    {
        'kylechui/nvim-surround',
        config = true,
        keys = {
            { 'cs', mode = 'n' },
            { 'ds', mode = 'n' },
            { 'ys', mode = 'n' },
            { 'yS', mode = 'n' },
            { 'yss', mode = 'n' },
            { 'ySs', mode = 'n' },
        },
    },
    {
        'tzachar/highlight-undo.nvim',
        config = true,
        keys = { 'u', 'U' },
    },
    {
        'kana/vim-textobj-user',
        dependencies = {
            {
                'kana/vim-textobj-entire',
                keys = {
                    { 'ae', mode = { 'o', 'x' } },
                    { 'ie', mode = { 'o', 'x' } },
                },
            },
            {
                'kana/vim-textobj-line',
                keys = {
                    { 'al', mode = { 'o', 'x' } },
                    { 'il', mode = { 'o', 'x' } },
                },
            },
            {
                'kana/vim-textobj-indent',
                keys = {
                    { 'ai', mode = { 'o', 'x' } },
                    { 'ii', mode = { 'o', 'x' } },
                },
            },
            {
                'preservim/vim-textobj-sentence',
                keys = {
                    { 'as', mode = { 'o', 'x' } },
                    { 'is', mode = { 'o', 'x' } },
                },
            },
            {
                'whatyouhide/vim-textobj-xmlattr',
                keys = {
                    { 'ax', mode = { 'o', 'x' } },
                    { 'ix', mode = { 'o', 'x' } },
                },
            },
        },
    },
    {
        'saghen/blink.indent',
        opts = {
            blocked = {
                filetypes = {
                    include_defaults = true,
                    'fugitive',
                    'markdown',
                    'typst',
                },
            },
            static = {
                char = '│',
            },
            scope = { enabled = false },
        },
    },
    {
        'barrettruth/midnight.nvim',
        dir = '~/dev/midnight.nvim',
        init = function()
            vim.api.nvim_create_autocmd({ 'OptionSet' }, {
                pattern = 'background',
                callback = function()
                    vim.cmd.colorscheme(
                        vim.o.background == 'dark' and 'midnight' or 'daylight'
                    )
                end,
                group = vim.api.nvim_create_augroup(
                    'AColorScheme',
                    { clear = true }
                ),
            })
        end,
    },
}
