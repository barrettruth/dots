---@type number|nil
local git_tab = nil

---@type string|nil
local prev = nil

return {
    {
        'tpope/vim-fugitive',
        config = function()
            vim.api.nvim_create_autocmd('TabClosed', {
                callback = function(args)
                    local closed_tab = tonumber(args.match)
                    if closed_tab == git_tab then
                        git_tab = nil
                    end
                end,
                group = vim.api.nvim_create_augroup(
                    'AFugitive',
                    { clear = true }
                ),
            })
        end,
        keys = {
            {
                desc = 'Toggle Fugitive Tab',
                '<leader>g',
                function()
                    local is_git_dir, _ = pcall(vim.fn['fugitive#repo'])
                    if not is_git_dir then
                        vim.notify(
                            'Working directory does not belong to a Git repository',
                            vim.log.levels.ERROR
                        )
                        return
                    end
                    if git_tab and vim.api.nvim_tabpage_is_valid(git_tab) then
                        if vim.api.nvim_get_current_tabpage() ~= git_tab then
                            vim.api.nvim_set_current_tabpage(git_tab)
                            return
                        end
                        vim.cmd.tabclose()
                        git_tab = nil
                        return
                    end
                    vim.cmd.tablast()
                    vim.cmd.tabnew()
                    local empty_buf = vim.api.nvim_get_current_buf()
                    vim.cmd.Git()
                    vim.cmd('silent only')
                    if
                        vim.api.nvim_buf_is_valid(empty_buf)
                        and vim.api.nvim_buf_get_name(empty_buf) == ''
                    then
                        vim.api.nvim_buf_delete(empty_buf, { force = true })
                    end
                    git_tab = vim.api.nvim_get_current_tabpage()
                end,
            },
        },
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
