---
name: kpl-doctor
description: >-
  Read-only health check of the KPL control plane (kit stamp, skills, hooks,
  AGENTS markers, stack.md). Use when: doctor, health check, verify install,
  after refresh, is the control plane ok. Not for: installing, refreshing, or
  writing app code.
---

# kpl-doctor

Readonly. Report only. Do not create or edit files.

## Checklist

List **FAIL** first, then **WARN**. Exit mentally as FAIL if any FAIL item.

1. `.kpl/agents/kpl-kit.json` exists with fields: `kit`, `repo`, `ref`, `installedAt` (and usually `mode`).
2. Present: `AGENTS.md`, `.kpl/agents/`, `.kpl/specs/SKILLS.md`, `.kpl/memory/INDEX.md`.
3. `.kpl/specs/stack.md` exists. **WARN** (not FAIL) if it still matches the unfilled template.
4. Every skill name in the `.kpl/specs/SKILLS.md` table has `.kpl/agents/skills/<name>/SKILL.md`.
5. If `.cursor/` exists: `.cursor/hooks.json` contains `kpl-check-read`.
6. If `.claude/` exists: `.claude/settings.json` contains `kpl-check-read`.
7. If `.opencode/` exists: `.opencode/plugins/kpl-bulk-read.js` exists.
8. `AGENTS.md` contains `<!-- kpl:user:start -->` and `<!-- kpl:user:end -->`.

## Optional script

If this kit repo is available beside the target:

```text
powershell -NoProfile -ExecutionPolicy Bypass -File <kit>/scripts/kpl-doctor.ps1 -Target <target>
# or: bash <kit>/scripts/kpl-doctor.sh <target>
```

## Output

FAIL items first; then WARN; then a one-line PASS / PASS with WARN / FAILED summary.
