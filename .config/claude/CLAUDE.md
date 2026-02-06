# Global Claude Code User Preferences

Never, under any circumstances, generate code containing new, non-preexisting comments.

Never, under any circumstances, respond with excerpts of code with no
explanation unless explicitly specified.

Never, under any circumstances, create commits, stage files, or create pull
requests unless explicitly specified.

If given express permission to use git, NEVER sign yourself as a contributor OR mention yourself in the PR.

If given express permission to use git, NEVER push to a main/master branch.

If given express permission to use git, NEVER commit ai-related files (e.g. CLAUDE.md).

If given express permission to use git, ALWAYS use this commit message format:

    type(scope): imperative summary

- Valid types: `feat` `fix` `docs` `refactor` `perf` `test` `ci` `build` `revert`
- Scope is optional, lowercase. Subject: lowercase after colon, no trailing period, max 72 chars.
- Body required for non-trivial commits, using `Problem:` / `Solution:` format.
- One logical change per commit. Refactors, formatting, and features must be separate commits.

If given express permission to use git, ALWAYS check for a PR template at
`.github/pull_request_template.md` and follow it. If none exists, use
Problem/Solution format as described in `~/.config/claude/rules/git.md`.

Never, under any circumstances, assume or fabricate APIs for
unknown/lesser-known services and APIs, such as NeoVim, NixOS, or other obscure
packages-always do your research first.
