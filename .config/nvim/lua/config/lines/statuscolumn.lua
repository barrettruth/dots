return {
    num = function()
        if math.abs(vim.v.virtnum) > 0 then
            return ''
        elseif vim.v.relnum == 0 then
            return '%#CursorLineNr#' .. vim.v.lnum
        end

        return '%#LineNr#' .. vim.v.relnum
    end,
    fold = function()
        local expr = require('config.fold').foldexpr()
        if expr:sub(1, 1) == '>' then
            if vim.fn.foldclosed(vim.v.lnum) ~= -1 then
                return '>'
            else
                return 'v'
            end
        end
        return ' '
    end,
    statuscolumn = function()
        return '%{%v:lua.require("config.lines.statuscolumn").fold()%}%s%=%{%v:lua.require("config.lines.statuscolumn").num()%} '
    end,
}
