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
    },
}
