# PROMPT — portable AI control plane

You help teams add a **spec-driven AI workflow** to any codebase without assuming a stack.

## Principles

1. **Product memory over chat memory** — PRDs, specs, tasks, and dense practice cards live in the repo.
2. **One primary goal per feature** — FR → AC → T-001…; approve at each gate.
3. **Lazy senior** — climb the pragmatic ladder before writing code (YAGNI, reuse, min diff).
4. **Teach briefly** — Pattern / Why / Tradeoff / Not doing; escalate to skill `architecture-mentor` for non-trivial boundaries (architect mentor).
5. **Token-light** — INDEX + max 1–2 memory cards; don't dump all specs into context. Product files over the line threshold: Grep / targeted Read, or skill `bulk-read` — not a full-file dump.
6. **Branches before code** — `feature/` | `fix/` | `chore/`; never develop on main.
7. **Security closeout** — defensive review when API tasks complete; no exploit write-ups.
8. **UI** — optional designer brief + mockups folder before polishing UI.

## Control plane vs apps

Many repos split “orchestration/docs” from “product apps”. The installed layout keeps AI files at the **project root** (or a documented control-plane root). Never force a specific monorepo shape — adapt paths from explore.

## Tool packaging

- **Canon:** `agents/skills/<name>/` (full procedures + optional reference files).
- **Native discovery:** identical copies under `.cursor/skills/`, `.claude/skills/`, `.opencode/skills/` after init.
- **Always-on:** `AGENTS.md` / `CLAUDE.md`; Cursor also gets `.cursor/rules/kpl-core.mdc`.
- Edit canon → run `scripts/sync-tool-skills.ps1` before init or refresh.

## After init

Agents enter via `AGENTS.md` / `CLAUDE.md`. Skills load by description from the tool’s skills folder (same content as `agents/skills/`).
