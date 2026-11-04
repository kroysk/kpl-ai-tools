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
- User names **target root** (directory that will receive `AGENTS.md`, `.kpl/agents/`, `.kpl/specs/`, …).

## Merge-safe rules

- **Never delete** existing `.kpl/specs/features/**`
- If the target **already has** a control plane and the user wants kit updates: stop and use skill **`kpl-sdd-refresh`** (installers `-Refresh` / `--refresh`) instead of re-running this init
- Don't touch application source (`src/`, `app/`, etc.)
- For `.opencode/opencode.json`: copy from templates **only if missing** (do not overwrite user config)
- For `.cursor/hooks.json` and `.claude/settings.json`: **merge** KPL token-I/O hooks (run kit `scripts/merge-kpl-io-hooks.ps1` or `.sh`); never replace the whole file

## Install steps

1. Read explore report; note apps paths, language, auth, control-plane root.
2. If `templates/.kpl/agents/skills` was edited recently, run `scripts/sync-tool-skills.ps1` from kit root so tool packs match canon.
3. Copy from `templates/` into target:
   - `AGENTS.md`, `CLAUDE.md`
   - `.kpl/agents/` (README, STANDARDS, ARCHITECTURE, CONTROL_PLANE, rules/, skills/, hooks/, `io-policy.json` — full skill bodies + mentor refs)
   - `.kpl/specs/` (README, SKILLS, stack.md, contract/, _templates/)
   - `.kpl/memory/` (INDEX + example card + `_template-adr.md`)
   - Tool packs → target `.cursor/`, `.claude/`, `.opencode/` from `templates/tool-stubs/*`
     - Skills are **full copies** (not pointers): `.cursor/skills`, `.claude/skills`, `.opencode/skills`
     - Cursor rules: `kpl-core.mdc` (+ optional closeout/access/mockups)
     - OpenCode: `opencode.json` only if target lacks one; always merge `.opencode/plugins/`
     - Token I/O: `.kpl/agents/io-policy.json` + `.kpl/agents/hooks/` copy with `.kpl/agents/`; then run kit `scripts/merge-kpl-io-hooks.ps1` (Windows) or `scripts/merge-kpl-io-hooks.sh` (Unix) against the target
4. **Adapt**:
   - Fill `.kpl/specs/stack.md` from explore
   - Fill `.kpl/agents/CONTROL_PLANE.md` paths
   - Seed `.kpl/specs/contract/README.md` with known routes if any (else empty table + gap)
   - Put the project name (and any project-only notes) **inside** the `<!-- kpl:user:start -->` … `<!-- kpl:user:end -->` block in `AGENTS.md` — do not rewrite the kit canon above that block
   - Optionally fill `.kpl/agents/skills/architecture-mentor/stack-hooks.md` from stack
5. Write `.kpl/agents/kpl-kit.json`:
   ```json
   { "kit": "kpl-ai-tools", "repo": "<kit repo url or local path>", "ref": "<branch/tag>", "installedAt": "YYYY-MM-DD", "mode": "init" }
   ```
6. Optionally copy `practices/` into `.kpl/agents/practices/` for reference (rules already carry the practice text).
7. Write short `.kpl/specs/features/_bootstrap/README.md` noting init date + explore file used.
8. Report checklist to user:
   - [ ] AGENTS.md + CLAUDE.md present (with `kpl:user` markers)
   - [ ] `.kpl/agents/kpl-kit.json` written
   - [ ] `.kpl/agents/skills` (real procedures) + rules
   - [ ] `.kpl/specs/_templates` + SKILLS.md
   - [ ] `.kpl/memory/INDEX` (+ ADR template)
   - [ ] `.cursor` / `.claude` / `.opencode` skill packs
   - [ ] Token-io hooks on (`.cursor/hooks.json` merged, `.claude/settings.json` merged, `.opencode/plugins/kpl-bulk-read.js`)
   - [ ] Customize architecture-mentor **stack-hooks** for this framework next
   - [ ] Optional: run `kpl-doctor` on the target

## After init

User works with `sdd-onboard` (routes to the right entry) or goes directly to `feature-discovery` / `fix-bug` / `kpl-new-project` → … → publish using installed skills. Keep this kit around for future projects; no need to modify the target's app code from init alone.
