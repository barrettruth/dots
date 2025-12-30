return {
    setup = function()
        vim.o.statusline = '%!v:lua.require("config.lines.statusline").statusline()'
        vim.o.statuscolumn =
            '%!v:lua.require("config.lines.statuscolumn").statuscolumn()'
    end,
}
