# AGENTS.md — AI control plane

Entry for Cursor / OpenCode / Claude ([CLAUDE.md](CLAUDE.md)).

## Identity

This repo root holds **product memory** (`.kpl/specs/`) and **agent canon** (`.kpl/agents/`). Adapt paths if your control plane differs (see `.kpl/specs/stack.md`).

## Token protocol

1. Read this + **one** skill under `.kpl/agents/skills/<name>/SKILL.md` (or the same skill from `.cursor` / `.claude` / `.opencode` skills — identical bodies)
2. Skim `.kpl/memory/INDEX.md` → open max **1–2** cards
3. Load only the current `.kpl/specs/features/<id>/` files you need
4. Apply STANDARDS + pragmatic-ladder; don't paste them into chat
5. Product files ≥500 lines: `Grep` or `Read` with `offset`/`limit`; if a hook blocks a full Read, load skill `bulk-read` (`.kpl/agents/rules/token-io.md`)

## Cycle

Three entry points, one architect, present throughout — see `.kpl/agents/rules/sdd-cycle.md`:

- **New project** (no existing code) → `kpl-new-project`
- **Feature** (new capability/actor/route/data owner) → `feature-discovery`
- **Fix** (known files, no new capability/FR/trust boundary) → `fix-bug`

Feature and fix share the same cycle and rigor: Discover → PRD → specs+tasks →
designer brief → mockups → branch → implement → security → publish. Fix differs
only in branch prefix (`fix/`), a mandatory root-cause field, and usually
skipping the designer brief. Diff size never chooses the path — scope does.
Scope change on an open package: edit the PRD first.

## Branches

Never code on `main`. Prefixes: `feature/` | `fix/` | `chore/`

## Architecture mentor (always present, every flow)

Not an escalation-only sub-agent — a standing role. On every non-trivial
decision in **any** of the three flows above, give the brief contract (3–4
lines, `.kpl/agents/rules/architecture-mentor.md`): **Pattern / Why here /
Tradeoff / Not doing**, then ask once if the user wants it expanded. Prefer
boring; climb the ladder before inventing layers.

Escalate — load skill `architecture-mentor` for the deep workflow (Socratic
questions, pattern catalog, review checklist, ADR writing) when the change
crosses modules, auth, data ownership, a new trust boundary, starts a project
from scratch, or needs an ADR. See `.kpl/agents/ARCHITECTURE.md`.

## Skills

See `.kpl/specs/SKILLS.md`. Canon: `.kpl/agents/skills/`. Tool folders mirror the same files for discovery.

<!-- kpl:user:start -->
<!-- Project notes. Refresh keeps this block. -->
<!-- kpl:user:end -->
