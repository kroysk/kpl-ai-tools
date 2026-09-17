---
name: implement-from-spec
description: >-
  Implements ready specs on a non-main branch, climbing the pragmatic ladder,
  updating T-* status, and escalating architecture-mentor for non-trivial work.
  Use when: implement, build from spec, code the feature, ready specs + branch.
  Not for: coding on main, implementing without ready specs (unless user overrides),
  or skipping security closeout on API work.
---

# implement-from-spec

## Preconditions

- Specs **ready** (or user override documented).
- Branch ≠ `main`/`master` — create via `git-branch` first.
- Read only the current `specs/features/<id>/` files needed + max 1–2 memory cards.

## Steps

1. Confirm branch and open `tasks.md`.
2. Climb pragmatic ladder (`agents/rules/pragmatic-ladder.md`) before adding structure.
3. Non-trivial structure → `architecture-mentor` (Teach-on-implement or Decide); paste Architecture note in the reply.
4. Implement task-by-task; mark `T-*` done/blocked; keep session log short.
5. Apply STANDARDS / clean-solid; min diff; no unrequested deps.
6. UI: prefer `mockups/`; if empty, follow designer-brief or ask.
7. When API-touching T-* all done → `security-review-api` (and front if UI authz).
8. Optional: `publish-feature`.

## Hard rules

- Never develop on main.
- Server enforces access; UI hide is not security.
- Token protocol: don't dump all specs into context.
