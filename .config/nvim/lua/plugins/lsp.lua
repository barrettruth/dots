return {
    'neovim/nvim-lspconfig',
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                { path = '${3rd}/luv/library' },
            },
        },
    },
    {
        'saghen/blink.cmp',
        build = 'cargo build --release',
        dependencies = 'folke/lazydev.nvim',
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        event = { 'InsertEnter', 'CmdlineEnter' },
        config = function(_, opts)
            vim.o.pumheight = 15
            opts.completion.menu.max_height = vim.o.pumheight

            require('blink.cmp').setup(opts)
        end,
        opts = {
            keymap = {
                ['<c-p>'] = { 'select_prev' },
                ['<c-n>'] = { 'show', 'select_next' },
                ['<c-space>'] = {},
                ['<c-y>'] = {
                    function(cmp)
                        return cmp.snippet_active() and cmp.accept()
                            or cmp.select_and_accept()
                    end,
                    'snippet_forward',
                },
            },
            completion = {
                menu = {
                    auto_show = false,
                    scrollbar = false,
                    draw = {
                        columns = function(ctx)
                            if ctx.mode == 'cmdline' then
                                return {
                                    { 'label', 'label_description', gap = 1 },
                                }
                            else
                                return {
                                    { 'label', 'label_description' },
                                    { 'kind' },
                                }
                            end
                        end,
                    },
                },
            },
            cmdline = {
                completion = {
                    menu = {
                        auto_show = true,
                    },
                },
                keymap = {
                    ['<left>'] = false,
                    ['<right>'] = false,
                },
            },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
                providers = {
                    lazydev = {
                        name = 'LazyDev',
                        module = 'lazydev.integrations.blink',
                        score_offset = 100,
                    },
                },
            },
        },
        keys = { { '<c-n>', mode = 'i' } },
        opts_extend = { 'sources.default' },
    },
    {
        'nvimtools/none-ls.nvim',
        config = function()
            local null_ls = require('null-ls')
            local builtins = null_ls.builtins
            local code_actions, diagnostics, formatting, hover =
                builtins.code_actions,
                builtins.diagnostics,
                builtins.formatting,
                builtins.hover

            null_ls.setup({
                border = 'single',
                sources = {
                    require('none-ls.code_actions.eslint_d'),
                    code_actions.gitrebase,

                    diagnostics.buf,
                    diagnostics.checkmake,
                    require('none-ls.diagnostics.cpplint').with({
                        extra_args = {
                            '--filter',
                            '-legal/copyright',
                            '-whitespace/indent',
                        },
                        prepend_extra_args = true,
                    }),
                    require('none-ls.diagnostics.eslint_d'),
                    diagnostics.hadolint,
                    diagnostics.mypy.with({
                        extra_args = { '--check-untyped-defs' },
                        runtime_condition = function(params)
                            return vim.fn.executable('mypy') == 1
                                and require('null-ls.utils').path.exists(
                                    params.bufname
                                )
                        end,
                    }),
                    diagnostics.selene,
                    diagnostics.vacuum,
                    diagnostics.zsh,

                    formatting.black,
                    formatting.isort.with({
                        extra_args = { '--profile', 'black' },
                    }),
                    formatting.buf,
                    formatting.cbfmt,
                    formatting.cmake_format,
                    require('none-ls.formatting.latexindent'),
                    formatting.prettierd.with({
                        env = {
                            XDG_RUNTIME_DIR = vim.env.XDG_RUNTIME_DIR
                                or (
                                    (
                                        vim.env.XDG_DATA_HOME
                                        or (vim.env.HOME .. '/.local/share')
                                    )
                                    .. '/prettierd'
                                ),
                        },
                        extra_args = function(params)
                            if params.ft == 'jsonc' then
                                return { '--trailing-comma', 'none' }
                            end
                            return {}
                        end,
                        filetypes = {
                            'css',
                            'graphql',
                            'html',
                            'javascript',
                            'javascriptreact',
                            'json',
                            'jsonc',
                            'markdown',
                            'mdx',
                            'typescript',
                            'typescriptreact',
                            'yaml',
                        },
                    }),
                    formatting.shfmt.with({
                        extra_args = { '-i', '2' },
                    }),
                    formatting.stylua.with({
                        condition = function(utils)
                            return utils.root_has_file({
                                'stylua.toml',
                                '.stylua.toml',
                            })
                        end,
                    }),

                    hover.dictionary,
                    hover.printenv,
                },
                on_attach = require('config.lsp').on_attach,
                debounce = 0,
            })
        end,
        dependencies = 'nvimtools/none-ls-extras.nvim',
    },
    {
        'b0o/SchemaStore.nvim',
    },
    {
        'saecki/live-rename.nvim',
        event = 'LspAttach',
        config = function(_, opts)
            local live_rename = require('live-rename')

            live_rename.setup(opts)

            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(o)
                    local clients = vim.lsp.get_clients({ buffer = o.buf })
                    for _, client in ipairs(clients) do
                        if client:supports_method('textDocument/rename') then
                            bmap(
                                { 'n', 'grn', live_rename.rename },
                                { buffer = o.buf }
                            )
                        end
                    end
                end,
                group = vim.api.nvim_create_augroup(
                    'ALiveRename',
                    { clear = true }
                ),
            })
        end,
        keys = { 'grn' },
    },
    {
        'yioneko/nvim-vtsls',
        config = function(_, opts)
            require('vtsls').config(opts)
        end,
        dependencies = {
            {
                'davidosomething/format-ts-errors.nvim',
                ft = {
                    'javascript',
                    'javascriptreact',
                    'typescript',
                    'typescriptreact',
                },
            },
        },
        ft = {
            'javascript',
            'javascriptreact',
            'typescript',
            'typescriptreact',
        },
        opts = {
            on_attach = function(_, bufnr)
                bmap(
                    { 'n', 'gD', vim.cmd.VtsExec('goto_source_definition') },
                    { buffer = bufnr }
                )
            end,
            settings = {
                typescript = {
                    inlayHints = {
                        parameterNames = { enabled = 'literals' },
                        parameterTypes = { enabled = true },
                        variableTypes = { enabled = true },
                        propertyDeclarationTypes = { enabled = true },
                        functionLikeReturnTypes = { enabled = true },
                        enumMemberValues = { enabled = true },
                    },
                },
            },
            handlers = {
                ['textDocument/publishDiagnostics'] = function(_, result, ctx)
                    if not result.diagnostics then
                        return
                    end

                    local idx = 1
                    while idx <= #result.diagnostics do
                        local entry = result.diagnostics[idx]

                        local formatter =
                            require('format-ts-errors')[entry.code]
                        entry.message = formatter and formatter(entry.message)
                            or entry.message

                        if vim.tbl_contains({ 80001, 80006 }, entry.code) then
                            table.remove(result.diagnostics, idx)
                        else
                            idx = idx + 1
                        end
                    end

                    vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx)
                end,
            },
        },
    },
    {
        'pmizio/typescript-tools.nvim',
        opts = {
            on_attach = function(_, bufnr)
                bmap(
                    { 'n', 'gD', vim.cmd.TSToolsGoToSourceDefinition },
                    { buffer = bufnr }
                )
            end,
            handlers = {
                ['textDocument/publishDiagnostics'] = function(_, result, ctx)
                    if not result.diagnostics then
                        return
                    end

                    local idx = 1
                    while idx <= #result.diagnostics do
                        local entry = result.diagnostics[idx]

                        local formatter =
                            require('format-ts-errors')[entry.code]
                        entry.message = formatter and formatter(entry.message)
                            or entry.message

                        if vim.tbl_contains({ 80001, 80006 }, entry.code) then
                            table.remove(result.diagnostics, idx)
                        else
                            idx = idx + 1
                        end
                    end

                    vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx)
                end,
            },

            settings = {
                expose_as_code_action = 'all',
                -- tsserver_path = vim.env.XDG_DATA_HOME .. '/pnpm/tsserver',
                tsserver_file_preferences = {
                    includeInlayarameterNameHints = 'all',
                    includeInlayarameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                },
            },
        },
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        ft = {
            'javascript',
            'javascriptreact',
            'typescript',
            'typescriptreact',
        },
    },
    {
        'mrcjkb/rustaceanvim',
        ft = { 'rust' },
    },
    {
        'SmiteshP/nvim-navic',
        opts = {
            depth_limit = 3,
            depth_limit_indicator = '…',
            icons = {
                enabled = false,
            },
        },
        event = 'LspAttach',
    },
    {
        'chomosuke/typst-preview.nvim',
        ft = 'typst',
        version = '1.*',
        opts = {
            open_cmd = ('%s %%s --new-window'):format(vim.env.BROWSER),
            invert_colors = 'auto',
            dependencies_bin = {
                tinymist = vim.fn.exepath('tinymist'),
                websocat = vim.fn.exepath('websocat'),
            },
        },
        keys = { { '<leader>t', '<cmd>TypstPreviewToggle<cr>' } },
    },
}
