---
name: feature-discovery
description: >-
  Starts a feature with discovery.md under specs/features/<id>/. Clarifies goal,
  actor, layers, access, and open questions; waits for human approval before PRD.
  Use when: vague idea, new feature, discovery, kickoff, explore a product idea.
  Not for: implementing code, writing PRD before discovery approved, or trivial bugs.
---

# feature-discovery

## Preconditions

- Control plane present (`AGENTS.md`, `specs/`).
- User has a feature idea (may be vague). Ask ≤8 clarifying questions if needed.

## Steps

1. Propose `id` slug (kebab-case) and path `specs/features/<id>/`.
2. Create `discovery.md` from `specs/_templates/discovery.md`.
3. Fill: Primary goal, Intent (≤30 words), Actor, Layers, Assumptions, Open questions (max 5), Done when, Access matrix if HTTP, Out of scope.
4. Mark status `awaiting_approval`. Checklist: gate PASS only when content is coherent; **human approved** required.
5. Stop. Do **not** write PRD or code until user approves.

## Output

- File: `specs/features/<id>/discovery.md`
- Tell user: approve discovery → next skill `write-prd`.

## Rules

- One primary goal. No speculative FRs yet.
- HTTP: never leave access TBD — use `access: public` or `access: permission:<code>` (or note “no HTTP”).
