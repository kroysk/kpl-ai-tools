---
name: kpl-sdd-init
description: >-
  Installs an agnostic SDD/AI workflow (agents, specs, memory, full tool skills)
  into a target project from kpl-ai-tools templates. Merge-safe. Use after
  kpl-project-explore approval or when user asks to init SDD/AI tooling.
---

# kpl-sdd-init

Kit root = parent of `skills/` (this package). Templates = `templates/`.

## Preconditions

- Prefer an approved `out/explore-*.md`. If missing and user insists: run a **minimal** explore first (scan + assume defaults; note assumptions).
- User names **target root** (directory that will receive `AGENTS.md`, `agents/`, `specs/`, …).

## Merge-safe rules

- **Never delete** existing `specs/features/**`
- If `agents/` or `specs/` exist: overwrite only scaffold files listed below unless user says `refresh-all` (still skip features/)
- Don't touch application source (`src/`, `app/`, etc.)
- For `.opencode/opencode.json`: copy from templates **only if missing** (do not overwrite user config)
- For `.cursor/hooks.json` and `.claude/settings.json`: **merge** KPL token-I/O hooks (run kit `scripts/merge-kpl-io-hooks.ps1` or `.sh`); never replace the whole file

## Install steps

1. Read explore report; note apps paths, language, auth, control-plane root.
2. If `templates/agents/skills` was edited recently, run `scripts/sync-tool-skills.ps1` from kit root so tool packs match canon.
3. Copy from `templates/` into target:
   - `AGENTS.md`, `CLAUDE.md`
   - `agents/` (README, STANDARDS, ARCHITECTURE, CONTROL_PLANE, rules/, skills/, hooks/, `io-policy.json` — full skill bodies + mentor refs)
   - `specs/` (README, SKILLS, stack.md, contract/, _templates/)
   - `memory/` (INDEX + example card + `_template-adr.md`)
   - Tool packs → target `.cursor/`, `.claude/`, `.opencode/` from `templates/tool-stubs/*`
     - Skills are **full copies** (not pointers): `.cursor/skills`, `.claude/skills`, `.opencode/skills`
     - Cursor rules: `kpl-core.mdc` (+ optional closeout/access/mockups)
     - OpenCode: `opencode.json` only if target lacks one; always merge `.opencode/plugins/`
     - Token I/O: `agents/io-policy.json` + `agents/hooks/` copy with `agents/`; then run kit `scripts/merge-kpl-io-hooks.ps1` (Windows) or `scripts/merge-kpl-io-hooks.sh` (Unix) against the target
4. **Adapt**:
   - Fill `specs/stack.md` from explore
   - Fill `agents/CONTROL_PLANE.md` paths
   - Seed `specs/contract/README.md` with known routes if any (else empty table + gap)
   - Adjust `AGENTS.md` wording to project name
   - Optionally fill `agents/skills/architecture-mentor/stack-hooks.md` from stack
5. Optionally copy `practices/` into `agents/practices/` for reference (rules already carry the practice text).
6. Write short `specs/features/_bootstrap/README.md` noting init date + explore file used.
7. Report checklist to user:
   - [ ] AGENTS.md + CLAUDE.md present
   - [ ] agents/skills (real procedures) + rules
   - [ ] specs/_templates + SKILLS.md
   - [ ] memory/INDEX (+ ADR template)
   - [ ] `.cursor` / `.claude` / `.opencode` skill packs
   - [ ] Token-io hooks on (`.cursor/hooks.json` merged, `.claude/settings.json` merged, `.opencode/plugins/kpl-bulk-read.js`)
   - [ ] Customize architecture-mentor **stack-hooks** for this framework next

## After init

User works with feature-discovery → … → publish using installed skills. Keep this kit around for future projects; no need to modify the target’s app code from init alone.
