local function executable(name)
    return vim.fn.executable(name) == 1
end

return {
    'nvimdev/guard.nvim',
    dependencies = {
        {
            'nvimdev/guard-collection',
            dir = vim.fn.expand('~/dev/guard-collection'),
        },
    },
    config = function()
        vim.g.guard_config = {
            fmt_on_save = false,
            save_on_fmt = true,
            lsp_as_default_formatter = true,
        }

        local ft = require('guard.filetype')

        local py_fmt = executable('isort') or executable('black')
        if py_fmt then
            if executable('isort') and executable('black') then
                ft('python')
                    :fmt({
                        cmd = 'isort',
                        args = { '--profile', 'black', '-' },
                        stdin = true,
                    })
                    :append('black')
            elseif executable('isort') then
                ft('python'):fmt({
                    cmd = 'isort',
                    args = { '--profile', 'black', '-' },
                    stdin = true,
                })
            elseif executable('black') then
                ft('python'):fmt('black')
            end
        end

        if executable('mypy') then
            ft('python'):lint('mypy')
        end

        if executable('stylua') then
            ft('lua'):fmt({
                cmd = 'stylua',
                args = { '-' },
                stdin = true,
                find = { 'stylua.toml', '.stylua.toml' },
            })
        end

        if executable('selene') then
            ft('lua'):lint('selene')
        end

        if executable('prettierd') then
            ft('javascript,javascriptreact,typescript,typescriptreact')
                :fmt('prettierd')
            ft('css,graphql,html,json,jsonc,mdx,yaml'):fmt('prettierd')
        end

        if executable('eslint_d') then
            ft('javascript,javascriptreact,typescript,typescriptreact')
                :lint('eslint_d')
        end

        if executable('shfmt') then
            ft('sh,bash,zsh'):fmt({
                cmd = 'shfmt',
                args = { '-i', '2' },
                stdin = true,
            })
        end

        if executable('zsh') then
            ft('zsh'):lint('zsh')
        end

        if executable('buf') then
            ft('proto'):fmt('buf'):lint('buf')
        end

        if executable('hadolint') then
            local base = require('guard-collection.linter.hadolint')
            ft('dockerfile'):lint({
                cmd = 'hadolint',
                args = { '--no-fail', '-f', 'json' },
                fname = true,
                parse = base.parse,
            })
        end

        if executable('latexindent') then
            ft('tex'):fmt('latexindent')
        end

        if executable('cmake-format') then
            ft('cmake'):fmt('cmake-format')
        end

        if executable('checkmake') then
            ft('make'):lint('checkmake')
        end

        if executable('cpplint') then
            local base = require('guard-collection.linter.cpplint')
            ft('cpp'):lint({
                fn = function(_, fname)
                    local co = assert(coroutine.running())
                    vim.system(
                        { 'cpplint', '--filter=-legal/copyright,-whitespace/indent', fname },
                        {},
                        function(r) coroutine.resume(co, r.stderr or '') end
                    )
                    return coroutine.yield()
                end,
                parse = base.parse,
            })
        end

        if executable('cbfmt') and executable('prettierd') then
            ft('markdown'):fmt('cbfmt'):append('prettierd')
        elseif executable('cbfmt') then
            ft('markdown'):fmt('cbfmt')
        elseif executable('prettierd') then
            ft('markdown'):fmt('prettierd')
        end
    end,
}
