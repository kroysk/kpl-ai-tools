# CLAUDE.md

Follow [AGENTS.md](AGENTS.md).

- `.kpl/agents/STANDARDS.md`, `.kpl/agents/ARCHITECTURE.md`
- Rules (reference): `.kpl/agents/rules/`
- Skills: `.kpl/agents/skills/*/SKILL.md` — also discoverable as `.claude/skills/*/SKILL.md` (same content)
- Specs: `.kpl/specs/` · Memory: `.kpl/memory/INDEX.md` (max 1–2 cards)

## Always-on

Entries: `kpl-new-project` (greenfield) | `feature-discovery` (new capability) | `fix-bug` (known files, no new capability/FR/trust boundary) — same cycle/rigor for feature and fix, `fix/` branch + root-cause field for fixes. Diff size does not choose.
Branches: never on `main` (`feature/` | `fix/` | `chore/`).
Mentor: **present in all three entries**, every non-trivial step — Pattern / Why / Tradeoff / Not doing (3–4 lines), expand only if asked; load `architecture-mentor` for the deep dive on non-trivial boundaries or a new project's first ADR.
Ladder before layers. Token-light: one skill + 1–2 memory cards + current feature package only.
Product files ≥500 lines: Grep or Read with offset/limit; hook blocks → skill `bulk-read`.
