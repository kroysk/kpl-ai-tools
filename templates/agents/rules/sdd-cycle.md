# SDD cycle

Discover → approve → PRD (FR/AC) → approve → specs + `tasks.md` (T-001…) → optional designer brief + mockups → **git branch** → implement → security closeout → publish.

## Fix path vs feature path

Diff size does **not** choose the path.

**Fix path** — all four must hold:

1. Defect is already in known files
2. No new capability
3. No new FR
4. No new trust boundary

Then: `git-branch` with `fix/` → implement. Security closeout only if API or a trust boundary is touched.

**Feature path** — new capability, actor, route, or data owner. Full cycle with human gates.

Scope change on an open feature: edit the PRD first.

All feature packages live under `specs/features/<id>/` at the control-plane root.
