return {
    {
        'echasnovski/mini.pairs',
        config = true,
        event = 'InsertEnter',
    },
    {
        'echasnovski/mini.ai',
        opts = {
            custom_textobjects = {
                b = false,
                f = false,
                e = function(ai_type)
                    local n_lines = vim.fn.line('$')
                    local start_line, end_line = 1, n_lines
                    if ai_type == 'i' then
                        while start_line <= n_lines and vim.fn.getline(start_line):match('^%s*$') do
                            start_line = start_line + 1
                        end
                        while end_line >= start_line and vim.fn.getline(end_line):match('^%s*$') do
                            end_line = end_line - 1
                        end
                    end
                    local to_col = math.max(vim.fn.getline(end_line):len(), 1)
                    return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
                end,
                l = function(ai_type)
                    local line_num = vim.fn.line('.')
                    local line = vim.fn.getline(line_num)
                    if line == '' then
                        return { from = { line = line_num, col = 1 }, to = { line = line_num, col = 1 } }
                    end
                    local start_col, end_col
                    if ai_type == 'i' then
                        start_col = line:find('%S') or 1
                        end_col = line:match('.*%S()') or 1
                    else
                        start_col, end_col = 1, line:len()
                    end
                    return { from = { line = line_num, col = start_col }, to = { line = line_num, col = end_col } }
                end,
                I = function(ai_type)
                    local cur_line = vim.fn.line('.')
                    local cur_indent = vim.fn.indent(cur_line)
                    if vim.fn.getline(cur_line):match('^%s*$') then
                        local search_line = cur_line + 1
                        while search_line <= vim.fn.line('$') and vim.fn.getline(search_line):match('^%s*$') do
                            search_line = search_line + 1
                        end
                        if search_line <= vim.fn.line('$') then
                            cur_indent = vim.fn.indent(search_line)
                        end
                    end
                    local start_line, end_line = cur_line, cur_line
                    while start_line > 1 do
                        local prev = start_line - 1
                        local prev_blank = vim.fn.getline(prev):match('^%s*$')
                        if ai_type == 'i' and prev_blank then
                            break
                        end
                        if not prev_blank and vim.fn.indent(prev) < cur_indent then
                            break
                        end
                        start_line = prev
                    end
                    while end_line < vim.fn.line('$') do
                        local next = end_line + 1
                        local next_blank = vim.fn.getline(next):match('^%s*$')
                        if ai_type == 'i' and next_blank then
                            break
                        end
                        if not next_blank and vim.fn.indent(next) < cur_indent then
                            break
                        end
                        end_line = next
                    end
                    local to_col = math.max(vim.fn.getline(end_line):len(), 1)
                    return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
                end,
            },
        },
        keys = {
            { 'a', mode = { 'x', 'o' } },
            { 'i', mode = { 'x', 'o' } },
        },
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
        'saghen/blink.indent',
        opts = {
            blocked = {
                filetypes = {
                    include_defaults = true,
                    'fugitive',
                    'markdown',
                    'typst',
                    'git',
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
        enabled  = true,
        dir = '~/dev/midnight.nvim',
        config = function()
            vim.cmd.colorscheme('midnight')
        end,
    },
}
