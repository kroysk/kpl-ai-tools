# Agents canon

Edit skills and rules **here** (`templates/agents/` in the kit; `agents/` after init).

## Skills

Full procedures live in `skills/<name>/SKILL.md` (+ optional refs, e.g. architecture-mentor’s `patterns.md`).

After editing skill files in the **kit**, sync identical copies into the three tool packs:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-tool-skills.ps1
```

That updates `templates/tool-stubs/{cursor,claude,opencode}/skills/`. Init copies those into the target’s `.cursor/`, `.claude/`, `.opencode/`.

Do **not** maintain separate “pointer stubs” — tool folders must match canon byte-for-byte.

## Rules

- Source of truth for practice text: kit `practices/` → keep `agents/rules/` aligned (do not diverge).
- Cursor always-on: `kpl-core.mdc` (inline). Claude/OpenCode rely on `AGENTS.md` / `CLAUDE.md` (they do not load a `.rules` folder as skills).

## See also

- `STANDARDS.md`, `ARCHITECTURE.md`, `CONTROL_PLANE.md`
- Kit philosophy: `PROMPT.md`
