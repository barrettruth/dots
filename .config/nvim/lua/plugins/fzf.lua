return {
    'ibhagwan/fzf-lua',
    config = function(_, opts)
        require('fzf-lua').setup(opts)

        vim.api.nvim_create_autocmd('FileType', {
            pattern = 'fzf',
            callback = function()
                vim.opt_local.number = false
                vim.opt_local.relativenumber = false
            end,
            group = vim.api.nvim_create_augroup(
                'AFzfHighlights',
                { clear = true }
            ),
        })

        local ok, fzf_reload = pcall(require, 'config.fzf_reload')
        if ok then
            fzf_reload.setup(opts)
            fzf_reload.reload(true)
        end
    end,
    keys = {
        {
            '<c-t>',
            function()
                local fzf = require('fzf-lua')
                local git_dir = vim.fn
                    .system('git rev-parse --git-dir 2>/dev/null')
                    :gsub('\n', '')
                if vim.v.shell_error == 0 and git_dir ~= '' then
                    fzf.git_files({ cwd_prompt = false })
                else
                    fzf.files()
                end
            end,
        },
        { '<c-l>', '<cmd>FzfLua live_grep<cr>' },
        { '<leader>f/', '<cmd>FzfLua search_history<cr>' },
        { '<leader>f:', '<cmd>FzfLua command_history<cr>' },
        { '<leader>fa', '<cmd>FzfLua autocmds<cr>' },
        { '<leader>fB', '<cmd>FzfLua builtin<cr>' },
        { '<leader>fb', '<cmd>FzfLua buffers<cr>' },
        { '<leader>fc', '<cmd>FzfLua commands<cr>' },
        {
            '<leader>fe',
            '<cmd>FzfLua files cwd=~/.config<cr>',
        },
        {
            '<leader>ff',
            function()
                require('fzf-lua').files({ cwd = vim.fn.expand('%:h') })
            end,
        },
        {
            '<leader>fg',
            function()
                require('fzf-lua').live_grep({ cwd = vim.fn.expand('%:h') })
            end,
        },
        { '<leader>fH', '<cmd>FzfLua highlights<cr>' },
        { '<leader>fh', '<cmd>FzfLua help_tags<cr>' },
        { '<leader>fl', '<cmd>FzfLua loclist<cr>' },
        { '<leader>fm', '<cmd>FzfLua man_pages<cr>' },
        { '<leader>fq', '<cmd>FzfLua quickfix<cr>' },
        { '<leader>fr', '<cmd>FzfLua resume<cr>' },
        {
            '<leader>fs',
            '<cmd>FzfLua files cwd=~/.local/bin/scripts<cr>',
        },
        { '<leader>GB', '<cmd>FzfLua git_branches<cr>' },
        { '<leader>Gb', '<cmd>FzfLua git_worktrees<cr>' },
        { 'gq', '<cmd>FzfLua quickfix<cr>' },
        { 'gl', '<cmd>FzfLua loclist<cr>' },
    },
    opts = {
        files = {
            cmd = vim.env.FZF_CTRL_T_COMMAND,
            file_icons = false,
            no_header_i = true,
        },
        fzf_args = (vim.env.FZF_DEFAULT_OPTS or ''):gsub(
            '%-%-color=[^%s]+',
            ''
        ),
        grep = {
            file_icons = false,
            no_header_i = true,
            RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH,
        },
        lsp = {
            includeDeclaration = false,
            jump1 = true,
            symbols = {
                symbol_hl_prefix = '@',
                symbol_style = 3,
            },
        },
        winopts = {
            border = 'single',
            preview = {
                hidden = 'hidden',
            },
        },
        actions = {
            files = {
                default = function(...)
                    require('fzf-lua.actions').file_edit(...)
                end,
                ['ctrl-l'] = function(...)
                    local a = require('fzf-lua.actions')
                    a.file_sel_to_ll(...)
                    vim.cmd.lclose()
                end,
                ['ctrl-q'] = function(...)
                    local a = require('fzf-lua.actions')
                    a.file_sel_to_qf(...)
                    vim.cmd.cclose()
                end,
                ['ctrl-h'] = function(...)
                    require('fzf-lua.actions').toggle_hidden(...)
                end,
                ['ctrl-v'] = function(...)
                    require('fzf-lua.actions').file_vsplit(...)
                end,
                ['ctrl-x'] = function(...)
                    require('fzf-lua.actions').file_split(...)
                end,
            },
        },
        border = 'single',
        git = {
            files = {
                cmd = 'git ls-files --cached --others --exclude-standard',
            },
            worktrees = {
                fzf_args = ((vim.env.FZF_DEFAULT_OPTS or '')
                    :gsub('%-%-bind=ctrl%-a:select%-all', '')
                    :gsub('--color=[^%s]+', '')),
            },
            branches = {
                fzf_args = ((vim.env.FZF_DEFAULT_OPTS or '')
                    :gsub('%-%-bind=ctrl%-a:select%-all', '')
                    :gsub('--color=[^%s]+', '')),
            },
        },
    },
}
