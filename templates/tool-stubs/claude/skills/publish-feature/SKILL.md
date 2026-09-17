---
name: publish-feature
description: >-
  Records publish.md with branch/SHA/remote notes and guides a safe push of the
  working branch. Use when: publish, push feature, ship branch, publish.md.
  Not for: force-push to main, silent merge to main, or skipping security closeout.
---

# publish-feature

## Preconditions

- Work is on `feature/` | `fix/` | `chore/` (not main).
- API features: security-review done or explicitly deferred by user.

## Steps

1. Write/update `specs/features/<id>/publish.md` from `specs/_templates/publish.md` (repo, branch, SHA, remote, notes).
2. Push the **working branch** only if the user asks; no force; no silent merge to main.
3. Summarize what was published and any follow-ups (PR link if created when asked).

## Rules

Follow git-branches practice. Do not update git config.
