# AGENTS.md — kpl-ai-tools (kit)

This repository is the **portable SDD/AI workflow kit**, not a product app.

## What to do here

1. Load skill **`kpl-project-explore`** — explore a target project (readonly) → `out/explore-<slug>.md`
2. After human approval, load **`kpl-sdd-init`** — install templates into the target root

## Paths

| Need | Path |
| --- | --- |
| Kit skills (canon) | `skills/kpl-project-explore`, `skills/kpl-sdd-init` |
| Same skills (tool discovery) | `.cursor/skills/`, `.claude/skills/`, `.opencode/skills/` |
| Practices (upstream) | `practices/` |
| Install templates | `templates/` |
| Explore reports | `out/` |

## Do not

- Treat this kit as a product control plane (no `specs/features` cycle here unless you deliberately init another target)
- Edit only one tool’s skill copy — edit `templates/agents/skills/` then run `scripts/sync-tool-skills.ps1`; for kit skills edit `skills/` and mirror to the three tool folders

## After init on a target

The **target** project gets its own `AGENTS.md`, `agents/`, `specs/`, and tool skill packs. Develop features there.
