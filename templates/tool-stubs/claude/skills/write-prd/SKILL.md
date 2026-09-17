---
name: write-prd
description: >-
  Writes prd.md from an approved discovery: primary goal, FR (max 8), binary AC,
  endpoints without TBD, non-goals. Use when: discovery approved, write PRD,
  product requirements. Not for: coding, discovery not yet approved, or polishing UI.
---

# write-prd

## Preconditions

- `specs/features/<id>/discovery.md` status **approved** (or user explicitly overrides with noted risk).
- Template: `specs/_templates/prd.md`.

## Steps

1. Read approved discovery + `specs/stack.md` / access conventions if any.
2. Write `specs/features/<id>/prd.md`:
   - Primary goal, Problem, Non-goals
   - FR max **8**; AC binary and mapped to FR
   - Endpoints if HTTP — each with access; **no TBD**
   - Front show/hide if UI
   - Spec plan (which layers / `spec-*.md` files)
3. Status `draft` until human approves → then `approved`.
4. Stop for approval. Next: `write-feature-spec`.

## Architecture

If boundaries are unclear, run `architecture-mentor` (Decide) briefly and fold Non-goals / Spec plan accordingly.
