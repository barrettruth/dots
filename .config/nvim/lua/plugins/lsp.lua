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
        event = { 'InsertEnter', 'LspAttach' },
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
                enabled = false,
                --     completion = {
                --         menu = {
                --             auto_show = true,
                --         },
                --     },
                --     keymap = {
                --         ['<left>'] = false,
                --         ['<right>'] = false,
                --     },
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
