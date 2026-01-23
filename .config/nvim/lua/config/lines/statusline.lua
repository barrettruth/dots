local empty = require('config.utils').empty

local M = {}

local mode = {
    prefix = 'mode',
    -- highlight = 'white',
    value = function()
        local mode_to_text = {
            n = 'NORMAL',
            i = 'INSERT',
            v = 'VISUAL',
            V = 'V-LINE',
            ['\22'] = 'V-BLOCK',
            R = 'REPLACE',
            c = 'COMMAND',
        }

        return mode_to_text[vim.fn.mode()]
    end,
}

local file = {
    prefix = 'fp',
    -- highlight = 'blue',
    value = function()
        return vim.fn.expand('%:~')
        -- return vim.fn.pathshorten(vim.fn.expand('%:~'))
        -- return vim.fn.fnamemodify(
        --     vim.fn.bufname(vim.api.nvim_get_current_buf()),
        --     ':~:.'
        -- )
    end,
}

local git = {
    prefix = 'git',
    -- highlight = 'magenta',
    value = function()
        return vim.b.gitsigns_head
    end,
}

local modified = {
    value = function()
        return vim.api.nvim_get_option_value('modified', { buf = 0 }) and '+w'
            or ''
    end,
}

local navic = {
    prefix = 'loc',
    value = function()
        return require('nvim-navic').get_location()
    end,
    condition = function()
        local ok, _ = pcall(require, 'nvim-navic')
        return ok
    end,
}

local search = {
    prefix = '/',
    value = function()
        local count = vim.fn.searchcount({ maxcount = 999 })

        return string.format(
            '%s (%s/%d)',
            vim.fn.getreg('/'),
            count.current,
            count.total
        )
    end,
    condition = function()
        local status, searchcount = pcall(vim.fn.searchcount)

        if not status or not searchcount or vim.tbl_isempty(searchcount) then
            return false
        end

        return searchcount.total > 0
    end,
}

local filetype = {
    prefix = function()
        return empty(
            vim.api.nvim_get_option_value(
                'filetype',
                { buf = vim.api.nvim_get_current_buf() }
            )
        ) and 'bt' or 'ft'
    end,
    -- highlight = 'green',
    value = function()
        local ft = vim.api.nvim_get_option_value(
            'filetype',
            { buf = vim.api.nvim_get_current_buf() }
        )

        if empty(ft) then
            ft = vim.bo.buftype
        end

        return ft
    end,
}

local lineinfo = {
    prefix = 'lnnr',
    -- highlight = 'yellow',
    value = '%c:%l/%L',
}

M.components = {
    left = {
        [1] = mode,
        [2] = git,
        [3] = file,
        [4] = navic,
        [5] = modified,
    },
    right = {
        [1] = search,
        [2] = lineinfo,
        [3] = filetype,
    },
}

local format_components = require('config.lines.utils').format_components

M.statusline = function()
    return ('%s%%=%s'):format(
        format_components(M.components.left),
        format_components(M.components.right)
    )
end

return M
