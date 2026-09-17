---
name: write-feature-spec
description: >-
  Writes spec-<layer>.md and tasks.md from an approved PRD, including Architecture
  section and T-001… tasks. Use when: PRD approved, write specs, tasks, AC coverage.
  Not for: coding before specs ready, or discovery/PRD still draft.
---

# write-feature-spec

## Preconditions

- `prd.md` **approved**.
- Templates: `specs/_templates/feature-spec.md`, `specs/_templates/tasks.md`.

## Steps

1. Read PRD FR/AC and Spec plan.
2. For each layer in the plan, write `specs/features/<id>/spec-<layer>.md`:
   - Behavior, AC coverage, happy/error paths, endpoints
   - **Architecture**: boundaries, pattern, tradeoff/not doing
   - Concrete files to touch
3. If Architecture is non-trivial (new module, auth, data ownership, trust boundary): load `architecture-mentor` and fill the section from its output contract.
4. Write sibling `tasks.md`: max 12 rows `T-001…`; status pending; never delete done rows later.
5. Set specs to `ready` only when AC covered and tasks exist. Await human if still draft.

## Next

- UI surfaces → `write-designer-brief`
- Else → `git-branch` then `implement-from-spec`
