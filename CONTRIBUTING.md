# Contributing to Kephale AI Toolkit

Thanks for helping make **kpl-ai-tools** easier to use across Cursor, Claude Code, and OpenCode.

## Ground rules

- This repo is a **workflow kit**, not a product app. Do not run the full SDD feature cycle *inside* this kit unless you are deliberately testing init on a throwaway target.
- Prefer small, reviewable PRs.
- Keep skills **stack-agnostic** unless a file is explicitly a post-explore hook (e.g. `stack-hooks.md`).

## Where to edit

| What | Edit here | Then |
| --- | --- | --- |
| Product skills (after init) | `templates/agents/skills/<name>/` | Run sync (below) |
| Practices / always-on rules | `practices/` **and** matching `templates/agents/rules/` | Keep them aligned |
| Kit entry skills | `skills/kpl-project-explore`, `skills/kpl-sdd-init` | Mirror into `.cursor/skills/`, `.claude/skills/`, `.opencode/skills/` |
| Target always-on docs | `templates/AGENTS.md`, `templates/CLAUDE.md` | — |

### Sync tool packs

After changing canonical product skills:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-tool-skills.ps1
```

This copies `templates/agents/skills/*` → `templates/tool-stubs/{cursor,claude,opencode}/skills/` (byte-identical). Do **not** hand-edit only one tool’s copy.

### Install scripts

End-user installers live in `scripts/install.sh` (Linux/macOS) and `scripts/install.ps1` (Windows). Keep merge-safe behavior aligned with `skills/kpl-sdd-init/SKILL.md` (preserve `specs/features/**`, skip overwriting `.opencode/opencode.json`, no app source).

## Pull requests

1. Describe **why** (user pain or discoverability), not only what files changed.
2. If you add a skill: `name` + `description` with WHAT + WHEN + NOT (third person).
3. Do not commit secrets, real customer specs, or explore reports with private paths under `out/`.

## Security / mentor content

Security skills stay **defensive only** — no exploit steps, payloads, or attack PoCs.

## Questions

Open an issue with the label idea or docs. Star the repo if the toolkit helps — it improves discoverability for everyone.
