# guard.nvim Migration

## Status: Complete + PRs Ready

Using local fork at `~/dev/guard-collection` (branch: `all-features`)

## Fork Branches (ready for PRs)

| Branch | Tool | Type |
|--------|------|------|
| `feat/buf-formatter` | buf | formatter |
| `feat/buf-linter` | buf | linter |
| `feat/cmake-format-formatter` | cmake-format | formatter |
| `feat/zsh-linter` | zsh | linter |
| `feat/checkmake-linter` | checkmake | linter |
| `feat/cpplint-linter` | cpplint | linter |

All pushed to `github.com/barrettruth/guard-collection`

## Local Overrides

- **hadolint**: `-f json` instead of `--format=json` (version compat)
- **cpplint**: `--filter=-legal/copyright,-whitespace/indent`

## Next: guard.nvim Feature Request

**Problem**: Tools like cpplint exit non-zero on lint errors, which guard treats as failure. This forces verbose custom `fn` to capture stderr.

**Proposed**: Add `ignore_exit_code = true` or `stderr = true` option:

```lua
-- Current (verbose)
ft('cpp'):lint({
    fn = function(_, fname)
        local co = assert(coroutine.running())
        vim.system({ 'cpplint', fname }, {}, function(r)
            coroutine.resume(co, r.stderr or '')
        end)
        return coroutine.yield()
    end,
    parse = base.parse,
})

-- Proposed (simple)
ft('cpp'):lint({
    cmd = 'cpplint',
    fname = true,
    stderr = true,  -- capture stderr instead of stdout
    ignore_exit_code = true,  -- don't treat non-zero as error
    parse = ...,
})
```

File issue at: https://github.com/nvimdev/guard.nvim/issues

## After PRs Merged

Remove `dir = ...` from guard.lua to use upstream.
