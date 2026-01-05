local projects = {
    {
        name = 'bmath',
        paths = { vim.env.HOME .. '/dev/bmath' },
        cmd = 'cmake -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build && ctest --test-dir build --output-on-failure',
    },
    {
        name = 'theCourseForum2',
        paths = { vim.env.HOME .. '/dev/theCourseForum2' },
        cmd = 'docker compose up',
    },
    {
        name = 'atlas',
        paths = { vim.env.HOME .. '/dev/atlas' },
        cmd = 'pnpm dev',
    },
    {
        name = 'tinyground',
        paths = { vim.env.HOME .. '/dev/tinyground' },
        cmd = 'pnpm dev',
    },
    {
        name = 'interview-prep',
        paths = { vim.env.HOME .. '/dev/interview-prep' },
        cmd = 'pnpm dev',
    },
    {
        name = 'neovim',
        paths = { vim.env.HOME .. '/dev/neovim' },
        cmd = 'make',
    },
    {
        name = 'TestCppClient',
        paths = { vim.env.HOME .. '/dev/TestCppClient' },
        cmd = 'rm -f TestCppClientStatic && cmake -S . -B build/ && make && ./TestCppClientStatic',
    },
    {
        name = 'barrettruth.com',
        paths = { vim.env.HOME .. '/dev/barrettruth.com' },
        cmd = 'pnpm dev',
    },
    {
        name = 'sl',
        paths = { vim.env.HOME .. '/dev/sl' },
        cmd = 'doas make clean install && make clean',
    },
}

---@type number|nil
local overseer_tab = nil
---@type number|nil
local list_tab = nil
---@type any
local current_task = nil

return {
    'stevearc/overseer.nvim',
    init = function()
        vim.api.nvim_create_autocmd('VimLeavePre', {
            callback = function()
                local overseer = require('overseer')
                for _, task in ipairs(overseer.list_tasks()) do
                    if task:is_running() then
                        task:stop()
                    end
                    task:dispose(true)
                end
                current_task = nil
            end,
            group = vim.api.nvim_create_augroup('AOverseer', { clear = true }),
        })
    end,
    opts = {
        strategy = 'terminal',
        task_list = {
            bindings = {
                q = '<Cmd>OverseerClose<CR>',
            },
        },
    },
    keys = {
        { '<leader>Oa', '<cmd>OverseerTaskAction<cr>' },
        { '<leader>Ob', '<cmd>OverseerBuild<cr>' },
        {
            desc = 'Toggle Overseer Task View',
            '<leader>Ot',
            function()
                if list_tab and vim.api.nvim_tabpage_is_valid(list_tab) then
                    if vim.api.nvim_get_current_tabpage() ~= list_tab then
                        vim.api.nvim_set_current_tabpage(list_tab)
                        return
                    end
                    vim.cmd.tabclose()
                    list_tab = nil
                    return
                end
                vim.cmd.tabnew()
                vim.cmd.OverseerOpen()
                vim.cmd('silent only')
                list_tab = vim.api.nvim_get_current_tabpage()
            end,
        },
        {
            desc = 'Toggle Overseer Project View',
            '<leader>o',
            function()
                local overseer = require('overseer')
                local cwd = vim.fn.getcwd()
                local match = nil
                for _, p in ipairs(projects) do
                    if vim.tbl_contains(p.paths, cwd) then
                        match = p
                        break
                    end
                end
                if not match then
                    vim.notify(
                        'No task defined for this project',
                        vim.log.levels.WARN
                    )
                    return
                end

                local function has_overseer_buf(tab)
                    if not current_task then
                        return false
                    end
                    local bufnr = current_task:get_bufnr()
                    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
                        return false
                    end
                    local wins = vim.api.nvim_tabpage_list_wins(tab)
                    for _, win in ipairs(wins) do
                        if vim.api.nvim_win_get_buf(win) == bufnr then
                            return true
                        end
                    end
                    return false
                end

                if
                    overseer_tab
                    and vim.api.nvim_tabpage_is_valid(overseer_tab)
                    and not has_overseer_buf(overseer_tab)
                then
                    local prev_tab = vim.api.nvim_get_current_tabpage()
                    vim.api.nvim_set_current_tabpage(overseer_tab)
                    vim.cmd.tabclose()
                    overseer_tab = nil
                    if
                        prev_tab ~= overseer_tab
                        and vim.api.nvim_tabpage_is_valid(prev_tab)
                    then
                        vim.api.nvim_set_current_tabpage(prev_tab)
                    end
                end

                if
                    overseer_tab and vim.api.nvim_tabpage_is_valid(overseer_tab)
                then
                    if vim.api.nvim_get_current_tabpage() == overseer_tab then
                        vim.cmd.tabclose()
                        overseer_tab = nil
                        return
                    end
                    vim.api.nvim_set_current_tabpage(overseer_tab)
                    return
                end

                if
                    current_task
                    and (
                        current_task.cwd ~= cwd
                        or current_task.name ~= match.name
                    )
                then
                    if current_task:is_running() then
                        current_task:stop()
                    end
                    current_task:dispose(true)
                    current_task = nil
                end

                if not current_task or not current_task:is_running() then
                    local cmd = match.prefix_slock
                            and cwd:match('/slock$')
                            and vim.list_extend(
                                { 'doas' },
                                vim.split(match.cmd, ' ')
                            )
                        or match.cmd

                    current_task = overseer.new_task({
                        name = match.name,
                        cmd = cmd,
                        cwd = cwd,
                        env = match.env,
                    })
                    current_task:start()
                end

                vim.cmd.tablast()
                vim.cmd.tabnew()
                local empty_buf = vim.api.nvim_get_current_buf()
                current_task:open_output()
                vim.cmd('silent only')
                if
                    vim.api.nvim_buf_is_valid(empty_buf)
                    and vim.api.nvim_buf_get_name(empty_buf) == ''
                then
                    vim.api.nvim_buf_delete(empty_buf, { force = true })
                end
                overseer_tab = vim.api.nvim_get_current_tabpage()
            end,
        },
    },
}
