local api, au = vim.api, vim.api.nvim_create_autocmd

local aug = api.nvim_create_augroup('AAugs', { clear = true })

au('BufEnter', {
    command = 'setl formatoptions-=cro spelloptions=camel,noplainbuffer',
    group = aug,
})

au('BufWritePost', {
    pattern = (vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. '/.config'))
        .. '/firefox/userChrome.css',
    callback = function()
        if not vim.tbl_contains({ 'firefox', 'zen-browser' }, vim.env.BROWSER) then
            return
        end
        vim.notify(
            'Updating firefox-based browser userChrome.css...',
            vim.log.levels.INFO
        )
        local src = (vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. '/.config'))
            .. '/firefox/userChrome.css'
        local targets =
            vim.fn.glob(vim.env.HOME .. '/.zen/*release*/chrome', true, true)
        for _, dir in ipairs(targets) do
            vim.fn.system({ 'cp', '-f', src, dir .. '/userChrome.css' })
        end
    end,
    group = aug,
})

au({ 'TermOpen', 'BufWinEnter' }, {
    callback = function(args)
        if vim.bo[args.buf].buftype == 'terminal' then
            vim.opt_local.number = true
            vim.opt_local.relativenumber = true
            vim.cmd.startinsert()
        end
    end,
    group = aug,
})

au('BufWritePost', {
    pattern = (
        os.getenv('XDG_CONFIG_HOME') or (os.getenv('HOME') .. '/.config')
    ) .. '/dunst/dunstrc',
    callback = function()
        vim.fn.system('killall dunst && nohup dunst &; disown')
    end,
    group = aug,
})

au('BufReadPost', {
    command = 'sil! normal g`"',
    group = aug,
})

au({ 'BufRead', 'BufNewFile' }, {
    pattern = '*/templates/*.html',
    callback = function(opts)
        vim.api.nvim_set_option_value(
            'filetype',
            'htmldjango',
            { buf = opts.buf }
        )
    end,
    group = aug,
})

au('TextYankPost', {
    callback = function()
        vim.highlight.on_yank({ higroup = 'Visual', timeout = 300 })
    end,
    group = aug,
})

au({ 'FocusLost', 'BufLeave', 'VimLeave' }, {
    pattern = '*',
    callback = function()
        vim.cmd('silent! wall')
    end,
    group = aug,
})

vim.api.nvim_create_autocmd('WinEnter', {
    group = aug,
    callback = function()
        vim.wo.cursorline = true
    end,
})

vim.api.nvim_create_autocmd('WinLeave', {
    group = aug,
    callback = function()
        vim.wo.cursorline = false
    end,
})
