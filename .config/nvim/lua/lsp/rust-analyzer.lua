return {
    standalone = false,
    capabilities = { general = { positionEncodings = { 'utf-16' } } },
    settings = {
        ['rust-analyzer'] = {
            checkOnSave = {
                overrideCommand = {
                    'cargo',
                    'clippy',
                    '--message-format=json',
                    '--',
                    '-W',
                    'clippy::expect_used',
                    '-W',
                    'clippy::pedantic',
                    '-W',
                    'clippy::unwrap_used',
                },
            },
        },
    },
    on_attach = function(...)
        require('config.lsp').on_attach(...)
        bmap({ 'n', '\\Rc', '<cmd>RustLsp codeAction<cr>' })
        bmap({ 'n', '\\Rm', '<cmd>RustLsp expandMacro<cr>' })
        bmap({ 'n', '\\Ro', '<cmd>RustLsp openCargo<cr>' })
    end,
}
