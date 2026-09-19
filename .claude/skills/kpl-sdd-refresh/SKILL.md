---
name: kpl-sdd-refresh
description: >-
  Refresh an existing target project's KPL control plane from the current
  kpl-ai-tools kit without wiping product specs or stack customizations.
  Use when: update kit, refresh SDD, pull new skills/hooks into a project that
  already has AGENTS.md. Not for: first-time install (use kpl-sdd-init).
---

# kpl-sdd-refresh

Kit root = parent of `skills/` (this package). Runs the installers in **refresh** mode.

## Preconditions

- Target already has `AGENTS.md` and `agents/` (control plane present).
- User names **target root** if unclear.
- Prefer a local kit checkout on the branch/tag to refresh from; otherwise installers clone `KPL_REPO_URL` @ `KPL_REF`.

## Preserve (never overwrite if present)

- `specs/features/**`
- `specs/stack.md`
- `specs/contract/README.md`
- `agents/CONTROL_PLANE.md`
- `**/architecture-mentor/stack-hooks.md` (agents + tool skill packs)
- `memory/INDEX.md` and existing `memory/cards/**`
- `.opencode/opencode.json`
- Existing Cursor/Claude hook entries (token-io hooks are **merged**)

## Update from kit

- `AGENTS.md`, `CLAUDE.md`
- `agents/` skills, rules, hooks, `io-policy.json`, STANDARDS, practices
- `specs/README.md`, `specs/SKILLS.md`, `specs/_templates/`
- `.cursor/skills` + `.cursor/rules/*.mdc`
- `.claude/skills`, `.opencode/skills` + `.opencode/plugins`
- Token-I/O hook merge via `scripts/merge-kpl-io-hooks.*`
- Append `## Refreshed YYYY-MM-DD` to `specs/features/_bootstrap/README.md`

## Steps

1. Confirm target path and that `AGENTS.md` + `agents/` exist.
2. From kit root, run one of:
   - Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install.ps1 -Refresh <target>`
   - Linux/macOS: `bash scripts/install.sh --refresh <target>`
3. Report checklist:
   - [ ] Skills / rules / hooks updated from kit
   - [ ] Token-io hooks merged
   - [ ] `specs/features/**` untouched
   - [ ] `stack.md` / `CONTROL_PLANE` / `stack-hooks` preserved
   - [ ] Bootstrap has a new Refreshed section
4. Tell user to reopen the project (or reload) so tools pick up new skills/hooks.

## Do not

- First-time init → use `kpl-sdd-init`
- Delete obsolete skills from the target (refresh is additive)
- Overwrite stack / CONTROL_PLANE / feature packages
- Touch application source (`src/`, `app/`, …)
