# SDD cycle

Three entry points, one shared cycle underneath. The architecture mentor is
present (brief) in all three — see `.kpl/agents/rules/architecture-mentor.md`.

## Entry points

| Entry | When | Skill |
| --- | --- | --- |
| **New project** | No existing code / greenfield | `kpl-new-project` |
| **Feature** | New capability, actor, route, or data owner | `feature-discovery` |
| **Fix** | Defect in known files, no new capability/FR/trust boundary | `fix-bug` |

Diff size does **not** choose the path. Scope does.

## Shared cycle (feature and fix — same rigor)

Discover → approve → PRD (FR/AC) → approve → specs + `tasks.md` (T-001…) →
optional designer brief + mockups → **git branch** → implement → security
closeout → publish.

**Fix path** differs only in:

1. `discovery.md` / `prd.md` carry `kind: fix` and a mandatory `Root cause` field.
2. Branch prefix is `fix/` (never `feature/`).
3. Security closeout only if an API or trust boundary is touched (note "N/A" otherwise).
4. Designer brief is almost always skipped (no new UI) — confirm, don't assume.

Everything else — human gates, PRD, spec, quality gate — is identical. This is
what makes a fix as trustworthy as a feature, not a shortcut around review.

## New project path

`kpl-new-project` replaces discovery with an architecture-mentor interview
(no code to explore yet), seeds `.kpl/specs/stack.md` + a first ADR, then **hands
off to `feature-discovery` for the first real feature** — same cycle from there.

## Scope changes

Scope change on an open feature or fix: edit the PRD first, don't silently grow `tasks.md`.

All packages (feature or fix) live under `.kpl/specs/features/<id>/` at the control-plane root.
