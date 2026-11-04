---
name: feature-discovery
description: >-
  Starts a feature with discovery.md under .kpl/specs/features/<id>/. Clarifies goal,
  actor, layers, access, and open questions; waits for human approval before PRD.
  Use when: vague idea, new feature, discovery, kickoff, explore a product idea.
  Not for: implementing code, writing PRD before discovery approved, fix-path bugs
  (known files, no new capability/FR/trust boundary — use fix-bug instead), or a
  project with no existing code (use kpl-new-project instead).
---

# feature-discovery

## Preconditions

- Control plane present (`AGENTS.md`, `.kpl/specs/`).
- User has a feature idea (may be vague). Ask ≤8 clarifying questions if needed.
- If the request already fits **fix path** (`.kpl/agents/rules/sdd-cycle.md`): stop; hand off to `fix-bug`. Do not open discovery.
- If there is no existing code to build on: stop; hand off to `kpl-new-project`.

## Steps

1. Propose `id` slug (kebab-case) and path `.kpl/specs/features/<id>/`.
2. Create `discovery.md` from `.kpl/specs/_templates/discovery.md`.
3. Fill: Primary goal, Intent (≤30 words), Actor, Layers, Assumptions, Open questions (max 5), Done when, Access matrix if HTTP, Out of scope.
4. Mark status `awaiting_approval`. Checklist: gate PASS only when content is coherent; **human approved** required.
5. Stop. Do **not** write PRD or code until user approves.

## Output

- File: `.kpl/specs/features/<id>/discovery.md`
- Tell user: approve discovery → next skill `write-prd`.

## Rules

- One primary goal. No speculative FRs yet.
- HTTP: never leave access TBD — use `access: public` or `access: permission:<code>` (or note “no HTTP”).
