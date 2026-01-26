local M = {}

local projects = {
    {
        name = 'bmath',
        paths = { vim.env.HOME .. '/dev/bmath' },
        cmd = 'cmake -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build && ctest --test-dir build --output-on-failure',
    },
    {
        name = 'neovim',
        paths = { vim.env.HOME .. '/dev/neovim' },
        cmd = 'make',
    },
    {
        name = 'barrettruth.com',
        paths = { vim.env.HOME .. '/dev/barrettruth.com' },
        cmd = 'pnpm dev',
    },
    {
        name = 'philipmruth.com',
        paths = { vim.env.HOME .. '/dev/philipmruth.com' },
        cmd = 'pnpm dev',
    },
}

---@type overseer.Task|nil
local current_task = nil

local actions = {
    nvim = function()
        local ok, oil = pcall(require, 'oil')

        if not ok then
            return
        end

        oil.open()
    end,
    git = function()
        vim.cmd.Git()
        vim.cmd.only()
    end,
    run = function()
        local ok, overseer = pcall(require, 'overseer')

        if not ok then
            return
        end

        local cwd = vim.fn.getcwd()
        local match = nil
        for _, p in ipairs(projects) do
            if vim.tbl_contains(p.paths, cwd) then
                match = p
                break
            end
        end
        if not match then
            vim.notify_once(
                'No task defined for this project',
                vim.log.levels.WARN
            )
            vim.cmd('q!')
            return
        end
        if
            current_task
            and (current_task.cwd ~= cwd or current_task.name ~= match.name)
        then
            if current_task:is_running() then
                current_task:stop()
            end
            current_task:dispose(true)
            current_task = nil
        end
        if not current_task or not current_task:is_running() then
            current_task = overseer.new_task({
                name = match.name,
                cmd = match.cmd,
                cwd = cwd,
                env = match.env,
            })
            current_task:start()
        end
        current_task:open_output()
    end,
}

function M.run(subcmd)
    if not subcmd then
        error('No subcommand provided')
    end

    if not vim.tbl_contains(vim.tbl_keys(actions), subcmd) then
        error('Invalid subcommand: ' .. subcmd)
    end

    actions[subcmd]()
end

return M
