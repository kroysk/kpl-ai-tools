---
name: sdd-onboard
description: >-
  Guided first walkthrough of the SDD cycle on a small real change. Stops at
  each human gate; does not implement code. Use when: onboard, first feature,
  walk me through SDD, learn the cycle. Not for: skipping gates, coding, or
  replacing feature-discovery on an already-approved discovery.
---

# sdd-onboard

Walk one **small real** change through the control plane. Stop at every human gate. Do **not** implement code in this skill.

## Preconditions

- Control plane present (`AGENTS.md`, `.kpl/specs/`). Prefer filled `.kpl/specs/stack.md`.
- User names a small change in **this** repo (or agrees to pick one).

## Steps

1. Classify with `.kpl/agents/rules/sdd-cycle.md` (architect's call, brief — see `.kpl/agents/rules/architecture-mentor.md`):
   - **New project** (no existing code) → hand off to `kpl-new-project` and stop.
   - **Fix** (known files, no new capability/FR/trust boundary) → hand off to `fix-bug` and stop. Diff size does not choose.
   - **Feature** → continue.
2. Load `feature-discovery`. Create `discovery.md`. Stop until the human approves.
3. After approval: load `write-prd`. Stop until the human approves.
4. After approval: load `write-feature-spec` (and tasks). Stop until specs are ready / human approves the Code gate.
5. Tell the user the next skills: `git-branch` → `implement-from-spec` → (later) `sdd-quality-gate` Closed → optional `publish-feature`. Do not run implement here.

## Rules

- One primary goal. Do not fast-forward past approval.
- Do not write application source.
- Optional: run or load `kpl-doctor` first if the install looks unsure.
