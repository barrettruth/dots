return {
    cmd = { 'emmet-language-server', '--stdio' },
    filetypes = {
        'astro',
        'css',
        'eruby',
        'html',
        'htmlangular',
        'htmldjango',
        'javascriptreact',
        'less',
        'pug',
        'sass',
        'scss',
        'svelte',
        'templ',
        'typescriptreact',
        'vue',
    },
    init_options = {
        showSuggestionsAsSnippets = true,
    },
    capabilities = {
        textDocument = {
            completion = {
                completionItem = { snippetSupport = true },
            },
        },
    },
}
