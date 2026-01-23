local utils = require('config.utils')

local M = {}

local function vorfn(val_or_fn)
    if type(val_or_fn) == 'function' then
        return val_or_fn()
    end

    return val_or_fn
end

function M.format_components(components)
    local side = {}

    for i = 1, #components do
        local component = components[i]

        local highlight = vim.env.THEME == 'midnight' and 'Normal'
            or component.highlight

        if
            vorfn(component.condition) ~= false
            and not utils.empty(vorfn(component.value))
        then
            side[#side + 1] = ('%%#%s#%s%%#%s#'):format(
                highlight,
                vorfn(component.value),
                component.highlight or 'Normal'
            )
        end
    end

    if #side > 0 then
        return (' %s '):format(table.concat(side, ' │ '))
    end

    return ''
end

return M
