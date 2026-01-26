--- @class Fold
local M = {}

---@param bufnr number the buffer number
---@return boolean whether the below foldexpr() is applicable to the buffer
local function is_foldexpr(bufnr)
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    return ok and parser
end

--- @return string Fold level (as string for foldexpr)
function M.foldexpr()
    local line = vim.v.lnum
    local bufnr = vim.api.nvim_get_current_buf()
    local foldnestmax = vim.wo.foldnestmax
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not ok or not parser then
        return '0'
    end
    local trees = parser:parse()
    if not trees or #trees == 0 then
        return '0'
    end
    local root = trees[1]:root()
    local line_text = vim.fn.getline(line)
    local positions = {}
    local first_col = line_text:match('^%s*()')
    if first_col and first_col <= #line_text then
        table.insert(positions, first_col - 1)
    end
    local last_col = line_text:find('%S%s*$')
    if last_col then
        table.insert(positions, last_col - 1)
    end
    if #positions == 0 then
        table.insert(positions, 0)
    end
    local function is_foldable(node_type)
        return
            -- functions/methods
            node_type == 'function_definition'
                or node_type == 'function_declaration'
                or node_type == 'method_definition'
                or node_type == 'method_declaration'
                or node_type == 'function_item'
                -- structs/unions
                or node_type == 'class_definition'
                or node_type == 'class_declaration'
                or node_type == 'class_specifier'
                or node_type == 'struct_item'
                or node_type == 'struct_specifier'
                or node_type == 'struct_type'
                -- interfaces
                or node_type == 'union_specifier'
                or node_type == 'interface_declaration'
                or node_type == 'interface_definition'
                or node_type == 'interface_type'
                -- type decls/defs
                or node_type == 'type_declaration'
                or node_type == 'type_definition'
                -- traits
                or node_type == 'trait_item'
                -- enums
                or node_type == 'enum_declaration'
                or node_type == 'enum_specifier'
                -- namespace/modules
                or node_type == 'enum_item'
                or node_type == 'impl_item'
                or node_type == 'namespace_definition'
                or node_type == 'namespace_declaration'
                or node_type == 'internal_module'
                or node_type == 'mod_item'
    end
    local function should_fold(n)
        if not n then
            return false
        end
        local srow, _, erow, _ = n:range()
        return (erow - srow + 1) >= vim.wo.foldminlines
    end
    local function nested_fold_level(node)
        if not node then
            return 0
        end
        local level = 0
        local temp = node
        while temp do
            if is_foldable(temp:type()) and should_fold(temp) then
                level = level + 1
            end
            temp = temp:parent()
        end
        return level
    end
    local function starts_on_line(n)
        local srow, _, _, _ = n:range()
        return srow + 1 == line
    end
    local max_level = 0
    local is_start = false
    for _, col in ipairs(positions) do
        local node =
            root:named_descendant_for_range(line - 1, col, line - 1, col)
        if node then
            local raw_level = nested_fold_level(node)
            max_level = math.max(max_level, math.min(raw_level, foldnestmax))
            local temp = node
            while temp do
                local this_level = nested_fold_level(temp)
                if
                    is_foldable(temp:type())
                    and should_fold(temp)
                    and starts_on_line(temp)
                    and this_level <= foldnestmax
                then
                    is_start = true
                end
                temp = temp:parent()
            end
        end
    end
    if max_level == 0 then
        return '0'
    end
    if is_start then
        return '>' .. max_level
    end
    return tostring(max_level)
end


function M.setup()
    vim.opt.fillchars:append({
        fold = ' ',
        foldopen = 'v',
        foldclose = '>',
        foldsep = ' ',
    })
    vim.o.foldlevel = 1
    vim.o.foldtext = ''
    vim.o.foldnestmax = 2
    vim.o.foldminlines = 5
    vim.api.nvim_create_autocmd('FileType', {
        pattern = '*',
        callback = function(opts)
            -- do not override fold settings if not applicable
            if is_foldexpr(opts.bufnr) then
                vim.wo.foldmethod = 'expr'
                vim.wo.foldexpr = 'v:lua.require("config.fold").foldexpr()'
            end
        end,
        group = vim.api.nvim_create_augroup('AFold', { clear = true }),
    })
end

return M
