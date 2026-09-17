# AGENTS.md — AI control plane

Entry for Cursor / OpenCode / Claude ([CLAUDE.md](CLAUDE.md)).

## Identity

This repo root holds **product memory** (`specs/`) and **agent canon** (`agents/`). Adapt paths if your control plane differs (see `specs/stack.md`).

## Token protocol

1. Read this + **one** skill under `agents/skills/<name>/SKILL.md` (or the same skill from `.cursor` / `.claude` / `.opencode` skills — identical bodies)
2. Skim `memory/INDEX.md` → open max **1–2** cards
3. Load only the current `specs/features/<id>/` files you need
4. Apply STANDARDS + pragmatic-ladder; don't paste them into chat

## Cycle

Discover → PRD → specs+tasks → designer brief → mockups → branch → implement → security → publish

## Branches

Never code on `main`. Prefixes: `feature/` | `fix/` | `chore/`

## Architecture mentor (always-on)

On design or non-trivial implement: **Pattern / Why here / Tradeoff / Not doing**. Prefer boring. Climb the ladder before inventing layers.

Escalate — load skill `architecture-mentor` when the change crosses modules, auth, data ownership, a new trust boundary, or needs an ADR. See `agents/ARCHITECTURE.md`.

## Skills

See `specs/SKILLS.md`. Canon: `agents/skills/`. Tool folders mirror the same files for discovery.
