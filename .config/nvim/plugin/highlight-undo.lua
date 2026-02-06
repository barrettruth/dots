local api = vim.api
local ns = api.nvim_create_namespace('highlight_undo')

api.nvim_set_hl(0, 'HighlightUndo', { link = 'IncSearch', default = true })

for _, key in ipairs({ 'u', '<C-r>', 'U' }) do
    vim.keymap.set('n', key, function()
        api.nvim_buf_attach(0, false, {
            on_bytes = function(_, buf, _, sr, sc, _, _, _, _, ner, nec)
                local er, ec = sr + ner, sc + nec
                if er >= api.nvim_buf_line_count(buf) then
                    ec = #(api.nvim_buf_get_lines(buf, -2, -1, false)[1] or '')
                end
                vim.schedule(function()
                    if not api.nvim_buf_is_valid(buf) then
                        return
                    end
                    vim.hl.range(buf, ns, 'HighlightUndo', { sr, sc }, { er, ec })
                    vim.defer_fn(function()
                        if api.nvim_buf_is_valid(buf) then
                            api.nvim_buf_clear_namespace(buf, ns, 0, -1)
                        end
                    end, 300)
                end)
                return true
            end,
        })
        return key
    end, { expr = true })
end
