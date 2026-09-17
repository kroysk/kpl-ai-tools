# CLAUDE.md

Follow [AGENTS.md](AGENTS.md).

- `agents/STANDARDS.md`, `agents/ARCHITECTURE.md`
- Rules (reference): `agents/rules/`
- Skills: `agents/skills/*/SKILL.md` — also discoverable as `.claude/skills/*/SKILL.md` (same content)
- Specs: `specs/` · Memory: `memory/INDEX.md` (max 1–2 cards)

## Always-on

Cycle: Discover → PRD → specs+tasks → designer → branch → implement → security → publish.  
Branches: never on `main` (`feature/` | `fix/` | `chore/`).  
Mentor: Pattern / Why / Tradeoff / Not doing; load `architecture-mentor` for non-trivial boundaries.  
Ladder before layers. Token-light: one skill + 1–2 memory cards + current feature package only.
