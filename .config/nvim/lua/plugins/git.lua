---@type string|nil
local prev_gitsigns_signcol = nil

return {
    {
        'tpope/vim-fugitive',
        cmd = { 'Git', 'G', 'Gread', 'Gwrite', 'Gdiffsplit', 'Gvdiffsplit' },
    },
    {
        'barrettruth/diffs.nvim',
        dir = '~/dev/diffs.nvim',
        init = function()
            vim.g.diffs = {
                debug = true,
                hide_prefix = true,
                highlights = {
                    vim = {
                        enabled = true,
                    },
                    intra = {
                        enabled = true,
                        algorithm = 'auto',
                        max_lines = 500,
                    },
                },
            }
        end,
    },
    {
        -- TODO: find out a way to remove this/better overall github integration
        'folke/snacks.nvim',
        ---@type snacks.Config
        opts = { gitbrowse = {} },
        keys = {
            { '<leader>Go', '<cmd>lua Snacks.gitbrowse()<cr>' },
            { '<leader>Gi', '<cmd>lua Snacks.picker.gh_issue()<cr>' },
            { '<leader>Gp', '<cmd>lua Snacks.picker.gh_pr()<cr>' },
        },
    },
    {
        'lewis6991/gitsigns.nvim',
        keys = {
            { '[g', '<cmd>Gitsigns next_hunk<cr>' },
            { ']g', '<cmd>Gitsigns prev_hunk<cr>' },
            { '<leader>Gb', '<cmd>Gitsigns toggle_current_line_blame<cr>' },
            {
                '<leader>Gs',
                function()
                    if vim.opt.signcolumn:get() == 'no' then
                        prev_gitsigns_signcol = vim.opt.signcolumn:get()
                        vim.opt.signcolumn = 'yes'
                    else
                        vim.opt.signcolumn = prev_gitsigns_signcol
                    end
                    vim.cmd.Gitsigns('toggle_signs')
                end,
            },
        },
        event = 'VeryLazy',
        opts = {
            current_line_blame_formatter_nc = function()
                return {}
            end,
            signs = {
                -- use boxdraw chars
                add = { text = '│' },
                change = { text = '│' },
                delete = { text = '＿' },
                topdelete = { text = '‾' },
                changedelete = { text = '│' },
            },
            signcolumn = false,
        },
    },
}
