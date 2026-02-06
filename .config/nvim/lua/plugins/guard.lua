return {
    'nvimdev/guard.nvim',
    dependencies = {
        { dir = '~/dev/guard-collection', 'barrettruth/guard-collection' },
    },
    init = function()
        vim.g.guard_config = {
            fmt_on_save = false,
            save_on_fmt = true,
            lsp_as_default_formatter = true,
        }
    end,
    config = function()
        local ft = require('guard.filetype')

        ft('python'):fmt({
            cmd = 'isort',
            args = { '--profile', 'black', '-' },
            stdin = true,
        }):append('black'):lint('mypy')

        ft('lua'):fmt('stylua'):lint('selene')

        ft('javascript,javascriptreact,typescript,typescriptreact'):fmt('prettierd'):lint('eslint_d')
        ft('css,graphql,html,json,jsonc,mdx,yaml'):fmt('prettierd')

        ft('sh,bash,zsh'):fmt({
            cmd = 'shfmt',
            args = { '-i', '2' },
            stdin = true,
        })
        ft('zsh'):lint('zsh')

        ft('proto'):fmt('buf'):lint('buf')
        ft('dockerfile'):lint('hadolint')
        ft('tex'):fmt('latexindent')
        ft('cmake'):fmt('cmake-format')
        ft('make'):lint('checkmake')
        ft('cpp'):lint('cpplint')
        ft('markdown'):fmt('cbfmt'):append('prettierd')
    end,
}
