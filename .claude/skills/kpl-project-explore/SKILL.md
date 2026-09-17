---
name: kpl-project-explore
description: >-
  Explores any codebase readonly, asks up to 8 clarifying questions, and writes
  an explore report. Use before kpl-sdd-init or when onboarding AI workflow to a
  new project. Trigger: project explore, kpl-project-explore, understand this repo.
---

# kpl-project-explore

Kit root: folder containing this skill (`kpl-ai-tools/`). Target = project to understand (ask user if unclear).

## Steps

1. **Readonly scan** of target:
   - Top-level dirs; README; docker-compose / Dockerfile
   - Lockfiles (`package.json`, `composer.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, …)
   - Monorepo signals (`apps/`, `packages/`, `services/`, workspaces)
   - Existing `agents/`, `specs/`, `AGENTS.md`, `CLAUDE.md`
   - Tool skill packs: `.cursor/skills/`, `.claude/skills/`, `.opencode/skills/`
   - Cursor rules: `.cursor/rules/`; OpenCode config: `.opencode/opencode.json` if present
2. **Ask ≤8 questions** (skip if already answered):
   1. Single repo vs multi-repo / monorepo shape?
   2. Where should the AI control plane live (repo root vs subfolder)?
   3. List product apps/packages and roles (api, web, admin, …)
   4. Auth model (none / session / JWT / other)?
   5. Deploy / env tooling (docker, CLI, PaaS)?
   6. Branch defaults (`main`?) and any existing conventions?
   7. Already using agents/specs/tool skills? Keep or replace?
   8. Docs language (es/en)?
3. Write `kpl-ai-tools/out/explore-<slug>.md` (slug from project name):
   - Stack map, paths, answers, risks/gaps, recommended init target path
4. **Do not** create agents/specs yet. Say next: run `kpl-sdd-init` after human approves explore.

## Output header

```markdown
---
project: <name>
target: <absolute-or-relative-path>
date: YYYY-MM-DD
status: draft | approved
---
```
