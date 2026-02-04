local clang_format_content = [[BasedOnStyle: LLVM
IndentWidth: 2
UseTab: Never

AllowShortIfStatementsOnASingleLine: Never
AllowShortLoopsOnASingleLine: false
AllowShortFunctionsOnASingleLine: None
AllowShortLambdasOnASingleLine: None
AllowShortBlocksOnASingleLine: Never
AllowShortEnumsOnASingleLine: false
AllowShortCaseExpressionOnASingleLine: false

BreakBeforeBraces: Attach
ColumnLimit: 100
AlignAfterOpenBracket: Align
BinPackArguments: false
BinPackParameters: false]]

return {
    'barrettruth/cp.nvim',
    dir = '~/dev/cp.nvim',
    cmd = 'CP',
    keys = {
        { '<leader>ce', '<cmd>CP edit<cr>' },
        { '<leader>cp', '<cmd>CP panel<cr>' },
        { '<leader>cP', '<cmd>CP pick<cr>' },
        { '<leader>cr', '<cmd>CP run all<cr>' },
        { '<leader>cd', '<cmd>CP run --debug<cr>' },
        { '<leader>cc', '<cmd>CP cache read<cr>' },
        { ']c', '<cmd>CP next<cr>' },
        { '[c', '<cmd>CP prev<cr>' },
    },
    dependencies = {
        'L3MON4D3/LuaSnip',
    },
    init = function()
        vim.g.cp_config = {
            debug = false,
            languages = {
                cpp = {
                    extension = 'cc',
                    commands = {
                        build = {
                            'g++',
                            '-std=c++23',
                            '-O2',
                            '-Wall',
                            '-Wextra',
                            '-Wpedantic',
                            '-Wshadow',
                            '-Wconversion',
                            '-Wformat=2',
                            '-Wfloat-equal',
                            '-Wundef',
                            '-fdiagnostics-color=always',
                            '-DLOCAL',
                            '{source}',
                            '-o',
                            '{binary}',
                        },
                        run = { '{binary}' },
                        debug = {
                            'g++',
                            '-std=c++23',
                            '-g3',
                            '-fsanitize=address,undefined',
                            '-fno-omit-frame-pointer',
                            '-fstack-protector-all',
                            '-D_GLIBCXX_DEBUG',
                            '-DLOCAL',
                            '{source}',
                            '-o',
                            '{binary}',
                        },
                    },
                },
                python = {
                    extension = 'py',
                    commands = {
                        run = { 'python', '{source}' },
                        debug = { 'python', '{source}' },
                    },
                },
            },
            platforms = {
                codeforces = {
                    enabled_languages = { 'cpp', 'python' },
                    default_language = 'cpp',
                },
                atcoder = {
                    enabled_languages = { 'cpp', 'python' },
                    default_language = 'cpp',
                },
                cses = {},
            },
            ui = {
                picker = 'fzf-lua',
                panel = { diff_modes = { 'side-by-side', 'git' } },
            },
            hooks = {
                setup_io_input = function(buf)
                    require('cp.helpers').clearcol(buf)
                end,
                setup_io_output = function(buf)
                    require('cp.helpers').clearcol(buf)
                end,
                before_run = function(_)
                    require('config.lsp').format({ async = true })
                end,
                before_debug = function(_)
                    require('config.lsp').format({ async = true })
                end,
                setup_code = function(state)
                    vim.opt_local.winbar = ''
                    vim.opt_local.foldlevel = 0
                    vim.opt_local.foldmethod = 'marker'
                    vim.opt_local.foldmarker = '{{{,}}}'
                    vim.opt_local.foldtext = ''
                    vim.diagnostic.enable(false)

                    local buf = vim.api.nvim_get_current_buf()
                    local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, true)
                    if #lines > 1 or (#lines == 1 and lines[1] ~= '') then
                        local pos = vim.api.nvim_win_get_cursor(0)
                        vim.api.nvim_win_set_cursor(0, pos)
                        return
                    end

                    local trigger = state.get_platform() or ''
                    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { trigger })
                    vim.api.nvim_win_set_cursor(0, { 1, #trigger })
                    vim.cmd.startinsert({ bang = true })
                    vim.schedule(function()
                        local ls = require('luasnip')
                        if ls.expandable() then
                            vim.api.nvim_create_autocmd('TextChanged', {
                                buffer = buf,
                                once = true,
                                callback = function()
                                    vim.schedule(function()
                                        local pos = vim.api.nvim_win_get_cursor(0)
                                        vim.api.nvim_win_set_cursor(0, pos)
                                    end)
                                end,
                            })
                            ls.expand()
                        end
                        vim.cmd.stopinsert()
                    end)
                    local clang_format_path = vim.fn.getcwd() .. '/.clang-format'
                    if vim.fn.filereadable(clang_format_path) == 0 then
                        vim.fn.writefile(
                            vim.split(clang_format_content, '\n'),
                            clang_format_path
                        )
                    end
                end,
            },
            filename = function(_, _, problem_id)
                return problem_id
            end,
        }
    end,
}
