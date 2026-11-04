---
name: write-designer-brief
description: >-
  Writes designer-brief.md and prepares mockups/ folder for UI handoff after PRD
  and specs. Use when: UI feature, designer brief, mockups, design handoff.
  Not for: API-only features, implementing pixels before brief, or discovery stage.
---

# write-designer-brief

## Preconditions

- PRD + relevant specs approved (or user accepts parallel work with noted risk).
- Template: `.kpl/specs/_templates/designer-brief.md`; mockups readme: `.kpl/specs/_templates/mockups/README.md`.

## Steps

1. Create `.kpl/specs/features/<id>/designer-brief.md`: goal, users, surfaces, flows→AC, screens/states, show/hide, copy, deliverables.
2. Ensure `.kpl/specs/features/<id>/mockups/` exists (copy guidance from template README).
3. Tell designer (or user): drop `01-….png` (etc.) into `mockups/`.
4. Implement UI only after mockups exist **or** user explicitly says follow brief without images.

## Rules

Follow `.kpl/agents/rules/designer-mockups.md`. Do not invent a visual system that contradicts project standards.
