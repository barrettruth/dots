map({
    'n',
    'gx',
    function()
        local url = vim.fn.expand('<cfile>', nil)

        if not url:match('https') and url:match('/') then
            url = 'https://github.com/' .. url
        end

        vim.fn.jobstart({ vim.env.BROWSER, url })
    end,
})

map({ { 'i', 'c' }, '<c-a>', '<esc>' })

for key, cmd in pairs({
    left = 'vertical resize -10',
    right = 'vertical resize +10',
    down = 'resize +10',
    up = 'resize -10',
}) do
    map({
        'n',
        ('<%s>'):format(key),
        function()
            vim.cmd(cmd)
        end,
    })
end

map({ 'n', 'J', 'mzJ`z' })

map({ 'x', 'p', '"_dp' })
map({ 'x', 'P', '"_dP' })
map({ 't', '<esc>', '<c-\\><c-n>' })

map({ 'n', '<leader>iw', '<cmd>setlocal wrap!<cr>' })
map({ 'n', '<leader>is', '<cmd>setlocal spell!<cr>' })
local state = nil

map({
    'n',
    '<leader>iz',
    function()
        if state then
            for k, v in pairs(state) do
                vim.opt_local[k] = v
            end
            state = nil
        else
            state = {
                number = vim.opt_local.number:get(),
                relativenumber = vim.opt_local.relativenumber:get(),
                signcolumn = vim.opt_local.signcolumn:get(),
                statuscolumn = vim.opt_local.statuscolumn:get(),
                laststatus = vim.opt_local.laststatus:get(),
                cmdheight = vim.opt_local.cmdheight:get(),
            }
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn = 'no'
            vim.opt_local.statuscolumn = ''
            vim.opt_local.laststatus = 0
            vim.opt_local.cmdheight = 0
        end
    end,
})
