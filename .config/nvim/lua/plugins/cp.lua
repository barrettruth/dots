local clang_format = [[BasedOnStyle: LLVM
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

local cpp_base = [[#include <bits/stdc++.h>  // {{{

#include <version>
#ifdef __cpp_lib_ranges_enumerate
#include <ranges>
namespace rv = std::views;
namespace rs = std::ranges;
#endif

#pragma GCC optimize("O2,unroll-loops")
#pragma GCC target("avx2,bmi,bmi2,lzcnt,popcnt")

using namespace std;

using i32 = int32_t;
using u32 = uint32_t;
using i64 = int64_t;
using u64 = uint64_t;
using f64 = double;
using f128 = long double;

#if __cplusplus >= 202002L
template <typename T>
constexpr T MIN = std::numeric_limits<T>::min();

template <typename T>
constexpr T MAX = std::numeric_limits<T>::max();
#endif

#ifdef LOCAL
#define db(...) std::print(__VA_ARGS__)
#define dbln(...) std::println(__VA_ARGS__)
#else
#define db(...)
#define dbln(...)
#endif
//  }}}

void solve() {
  <++>
}

int main() {  // {{{
  std::cin.exceptions(std::cin.failbit);
#ifdef LOCAL
  std::cerr.rdbuf(std::cout.rdbuf());
  std::cout.setf(std::ios::unitbuf);
  std::cerr.setf(std::ios::unitbuf);
#else
  std::cin.tie(nullptr)->sync_with_stdio(false);
#endif
]]

local cpp_single = cpp_base .. [[  solve();
  return 0;
}  // }}}]]

local cpp_multi = cpp_base .. [[  u32 tc = 1;
  std::cin >> tc;
  for (u32 t = 0; t < tc; ++t) {
    solve();
  }
  return 0;
}  // }}}]]

local templates = {
    cpp = {
        default = cpp_multi,
        codeforces = cpp_multi,
        atcoder = cpp_single,
        cses = cpp_single,
    },
    python = {
        default = [[def main() -> None:
    <++>


if __name__ == '__main__':
    main()]],
    },
}

local function insert_template(buf, lang, platform)
    local lang_templates = templates[lang]
    if not lang_templates then
        return false
    end

    local template = lang_templates[platform] or lang_templates.default
    if not template then
        return false
    end

    local lines = vim.split(template, '\n')
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    for lnum, line in ipairs(lines) do
        local col = line:find('<++>', 1, true)
        if col then
            local new_line = line:sub(1, col - 1) .. line:sub(col + 4)
            vim.api.nvim_buf_set_lines(buf, lnum - 1, lnum, false, { new_line })
            vim.api.nvim_win_set_cursor(0, { lnum, col - 1 })
            break
        end
    end

    return true
end

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
    init = function()
        vim.g.cp = {
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
                        return
                    end

                    local lang = state.get_language()
                    local platform = state.get_platform()
                    insert_template(buf, lang, platform)

                    local clang_format_path = vim.fn.getcwd() .. '/.clang-format'
                    if vim.fn.filereadable(clang_format_path) == 0 then
                        vim.fn.writefile(vim.split(clang_format, '\n'), clang_format_path)
                    end
                end,
            },
            filename = function(_, _, problem_id)
                return problem_id
            end,
        }
    end,
}
