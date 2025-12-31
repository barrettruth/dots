vim.g.mapleader = ' '

function _G.map(mapping, opts)
    vim.keymap.set(
        mapping[1],
        mapping[2],
        mapping[3],
        vim.tbl_extend('keep', opts or {}, { silent = true })
    )
end

function _G.bmap(mapping, opts)
    _G.map(mapping, vim.tbl_extend('force', opts or {}, { buffer = 0 }))
end

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        'git@github.com:folke/lazy.nvim.git',
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)
require('lazy').setup('plugins', {
    git = { url_format = 'git@github.com:%s.git' },
    change_detection = { enabled = false },
    performance = {
        cache = {
            enabled = true,
        },
        reset_packpath = true,
        rtp = {
            reset = true,
            disabled_plugins = {
                'gzip',
                'netrwPlugin',
                'tarPlugin',
                'tohtml',
                'tutor',
                'zipPlugin',
                '2html_plugin',
                'getscript',
                'getscriptPlugin',
                'logipat',
                'netrw',
                'netrwSettings',
                'netrwFileHandlers',
                'tar',
                'tarPlugin',
                'rrhelper',
                'vimball',
                'vimballPlugin',
                'zip',
                'zipPlugin',
                'tutor',
                'rplugin',
                'synmenu',
                'optwin',
                'bugreport',
            },
        },
    },
})
