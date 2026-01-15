---@type number|nil
local git_tab = nil

---@type string|nil
local prev = nil

return {
    {
        'tpope/vim-fugitive',
        cmd = 'Git',
    },
    {
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
                        prev = vim.opt.signcolumn:get()
                        vim.opt.signcolumn = 'yes'
                    else
                        vim.opt.signcolumn = prev
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
