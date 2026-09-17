# Kephale AI Toolkit

**Spec-driven AI workflow for [Cursor](https://cursor.com), [Claude Code](https://docs.anthropic.com/en/docs/claude-code), and [OpenCode](https://opencode.ai)** — repo: [`kpl-ai-tools`](.)

[![License: MIT](https://img.shields.io/badge/License-MIT-emerald.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Cursor](https://img.shields.io/badge/Cursor-skills-000000?logo=cursor&logoColor=white)](#works-with)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skills-d97706)](#works-with)
[![OpenCode](https://img.shields.io/badge/OpenCode-skills-0ea5e9)](#works-with)

> **Product memory in git beats chat memory.** Explore any codebase → install a portable SDD control plane → ship features with discovery, PRDs, specs, tasks, an architecture mentor, and security closeout — without locking you to one stack.

---

## Why it exists

| Pain | What Kephale does |
| --- | --- |
| Agents forget context every session | PRDs, specs, tasks, and dense memory cards live **in the repo** |
| “AI workflow” means random prompts | One gated cycle: Discover → PRD → Specs → Branch → Implement → Security → Publish |
| Skills only work in one IDE | **Native** packs for Cursor, Claude Code, and OpenCode |
| Over-engineered “enterprise” templates | Pragmatic ladder + architecture mentor that prefer **boring, correct** design |

Built for developers and teams who want AI help that still looks like senior engineering.

---

## Install from GitHub (Windows · Linux · macOS)

Install the SDD control plane **into your project** directly from this repo. Merge-safe: never deletes `specs/features/**`, never touches `src/` / `app/`.

### Windows (PowerShell)

From **your project root** (not from this kit):

```powershell
cd C:\path\to\your-project
$env:KPL_REPO_URL = "https://github.com/kroysk/kpl-ai-tools.git"
# optional: $env:KPL_REF = "main"
irm https://raw.githubusercontent.com/kroysk/kpl-ai-tools/main/scripts/install.ps1 | iex
```

Or with a local clone of the toolkit:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\path\to\kpl-ai-tools\scripts\install.ps1 C:\path\to\your-project
```

Requires [Git for Windows](https://git-scm.com/download/win).

### Linux

```bash
cd /path/to/your-project
export KPL_REPO_URL="https://github.com/kroysk/kpl-ai-tools.git"
# optional: export KPL_REF=main
curl -fsSL "https://raw.githubusercontent.com/kroysk/kpl-ai-tools/main/scripts/install.sh" | bash
```

Install into another directory:

```bash
curl -fsSL "https://raw.githubusercontent.com/kroysk/kpl-ai-tools/main/scripts/install.sh" | bash -s -- /path/to/your-project
```

Or from a local clone:

```bash
chmod +x /path/to/kpl-ai-tools/scripts/install.sh
/path/to/kpl-ai-tools/scripts/install.sh /path/to/your-project
```

### macOS

Same as Linux (Terminal or zsh):

```bash
cd /path/to/your-project
export KPL_REPO_URL="https://github.com/kroysk/kpl-ai-tools.git"
curl -fsSL "https://raw.githubusercontent.com/kroysk/kpl-ai-tools/main/scripts/install.sh" | bash
```

If `curl | bash` is blocked by policy, clone first then run the local script:

```bash
git clone https://github.com/kroysk/kpl-ai-tools.git
./kpl-ai-tools/scripts/install.sh /path/to/your-project
```

### After install

1. Open **your project** in Cursor / Claude Code / OpenCode  
2. Fill `specs/stack.md`  
3. Start with skill **`feature-discovery`**

Scripts: [`scripts/install.sh`](scripts/install.sh) · [`scripts/install.ps1`](scripts/install.ps1)

---

## Quick start (explore → init with the agent)

Prefer the agent when you want an explore report before install:

```text
1. Clone this repo and open it in Cursor | Claude Code | OpenCode
2. Ask:  Explore <path-to-your-project>   (skill: kpl-project-explore)
3. Approve out/explore-*.md
4. Ask:  Init the SDD workflow into <path>   (skill: kpl-sdd-init)
```

Skills auto-discover — invoke `/kpl-project-explore` or `/kpl-sdd-init`, or say it in plain language. **No need to paste file paths into the chat.**

`kpl-sdd-init` is merge-safe and **does not touch application source** (`src/`, `app/`, …) unless you ask for something else later.

### Example prompts

```text
Explore the project at ../my-app (kpl-project-explore).
```

```text
Explore approved. Init the SDD workflow into ../my-app (kpl-sdd-init).
```

---

## What you get

- **13 product skills** — discovery, PRD, specs/tasks, designer brief, implement-from-spec, quality gate, security reviews, git branch, publish, memory, endpoint access, **architecture mentor**
- **Architecture mentor** — Pattern / Why / Tradeoff / Not doing; pattern catalog + review checklist; escalates on real boundaries
- **Practices** — pragmatic ladder, Clean/SOLID, SDD cycle, git branches, memory protocol, security closeout, designer mockups
- **Templates** — `AGENTS.md`, `agents/`, `specs/`, `memory/`, ready for any language/framework
- **Token-light protocol** — INDEX + max 1–2 memory cards; don’t dump the whole specs tree into context

---

## Works with

Open **this** repo in any of the three tools — kit skills load immediately:

| Tool | Kit (this repo) | After init on a **target** project |
| --- | --- | --- |
| **Cursor** | `.cursor/skills/kpl-*` + `kpl-kit.mdc` | `.cursor/skills/*` + `kpl-core.mdc` |
| **Claude Code** | `.claude/skills/kpl-*` + `AGENTS.md` / `CLAUDE.md` | `.claude/skills/*` + `AGENTS.md` / `CLAUDE.md` |
| **OpenCode** | `.opencode/skills/kpl-*` + `opencode.json` | `.opencode/skills/*` + `opencode.json` (if missing) |

**Canon for product skills:** edit [`templates/agents/skills/`](templates/agents/skills/), then sync:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-tool-skills.ps1
```

Identical skill bodies land in `templates/tool-stubs/{cursor,claude,opencode}/skills/`.

---

## Feature workflow (after init)

```mermaid
flowchart LR
  Discover --> PRD --> Specs --> Designer --> Branch --> Implement --> Security --> Publish
```

Trivial bugs can skip the full cycle. Scope changes edit the PRD first. See [`PROMPT.md`](PROMPT.md) for the philosophy.

---

## Repo layout

| Path | Role |
| --- | --- |
| [PROMPT.md](PROMPT.md) | Philosophy |
| [AGENTS.md](AGENTS.md) / [CLAUDE.md](CLAUDE.md) | Kit entry for the three tools |
| [practices/](practices/) | Agnostic practice docs (upstream for `agents/rules`) |
| [templates/](templates/) | Files init copies into targets |
| [skills/](skills/) | Explore + init (mirrored to `.cursor` / `.claude` / `.opencode`) |
| [scripts/sync-tool-skills.ps1](scripts/sync-tool-skills.ps1) | Sync canon skills → tool packs |
| [scripts/install.sh](scripts/install.sh) / [install.ps1](scripts/install.ps1) | Install control plane from GitHub / local kit |
| [out/](out/) | Explore reports (gitignored contents) |

---

## Taking it to another machine

1. Use **Install from GitHub** above, **or** clone / vendor as `vendor/kpl-ai-tools`
2. Open the kit or the target project in your AI tool
3. Or run explore → init for a guided setup

Nothing changes in a target until you run **`install.sh` / `install.ps1`** or **`kpl-sdd-init`**.

---

## Contributing

PRs welcome — skills, practices, docs, and tool packaging. Start with [`CONTRIBUTING.md`](CONTRIBUTING.md).

Good first contributions: clearer skill descriptions, stack-agnostic examples, translations of docs, or fixing sync/docs drift.

---

## Author

Built as **Kephale AI Toolkit** (`kpl-ai-tools`) — a portable control plane so AI-assisted work stays reviewable, teachable, and stack-agnostic.

If this saves you a week of prompt archaeology, a **star** helps others find it and supports the project’s visibility.

---

## Suggested GitHub topics

When you publish the repo, add topics such as:

`kephale` · `ai-toolkit` · `cursor` · `claude-code` · `opencode` · `agent-skills` · `spec-driven-development` · `sdd` · `agents-md` · `architecture` · `developer-tools`

Repo: [github.com/kroysk/kpl-ai-tools](https://github.com/kroysk/kpl-ai-tools)

---

## License

[MIT](LICENSE) © 2026 Kephale
