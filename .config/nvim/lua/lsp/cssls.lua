return {
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = { 'css', 'scss', 'less' },
    settings = {
        css = {
            lint = {
                unknownAtRules = 'ignore',
            },
        },
    },
    capabilities = {
        textDocument = {
            completion = {
                completionItem = { snippetSupport = true },
            },
        },
    },
}
