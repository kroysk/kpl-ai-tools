---
name: git-branch
description: >-
  Creates a feature/fix/chore branch before code changes; never develops on main.
  Use when: new branch, start feature, git branch, before implement.
  Not for: force-push, rewriting main history, or committing unless user asks.
---

# git-branch

## Rules

Follow `agents/rules/git-branches.md`.

| Type | Prefix |
| --- | --- |
| Feature | `feature/` |
| Fix | `fix/` |
| Deps/tech | `chore/` |

## Steps

1. Confirm current branch; if on `main`/`master`, create new branch before any code edit.
2. Name: `<prefix><slug>` matching feature id when possible (same slug across packages).
3. Create and check out the branch (user’s git workflow; no force; no config changes).
4. Record branch name in `tasks.md` frontmatter `branches:` if present.
5. Hand off to `implement-from-spec` or the requested work.

## Do not

- Develop on main
- Force push
- Merge to main silently
