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

1. Confirm path: **fix path** (known files, no new capability/FR/trust boundary) → prefix `fix/`, no discovery. Otherwise use `feature/` or `chore/` from an approved feature package. Diff size does not choose. See `agents/rules/sdd-cycle.md`.
2. Confirm current branch; if on `main`/`master`, create new branch before any code edit.
3. Name: `<prefix><slug>` matching feature id when possible (same slug across packages).
4. Create and check out the branch (user’s git workflow; no force; no config changes).
5. Record branch name in `tasks.md` frontmatter `branches:` if present (feature path).
6. Hand off to `implement-from-spec` or the requested work.

## Do not

- Develop on main
- Force push
- Merge to main silently
