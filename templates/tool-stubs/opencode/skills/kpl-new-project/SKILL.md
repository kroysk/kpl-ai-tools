---
name: kpl-new-project
description: >-
  Bootstraps a brand-new project (no existing code to explore) with the
  architecture mentor driving stack/structure decisions, then seeds .kpl/specs/stack.md,
  a first ADR, and the _bootstrap feature package. Use when: new project, greenfield,
  starting from scratch, empty repo, what stack should I use. Not for: existing
  codebases (use kpl-project-explore + kpl-sdd-init) or adding a feature to code
  that already exists.
---

# kpl-new-project

Greenfield entry point. There is no code to explore, so the architecture mentor
leads with questions instead of reading files.

## Preconditions

- Target directory is empty or near-empty (no meaningful `src/`/`app/` to explore).
- If the target already has real code: stop, suggest `kpl-project-explore` + `kpl-sdd-init` instead.

## Steps

1. **Architect interview** (max 8 questions, skip any already answered): primary
   domain/goal, expected scale (hobby / team / production), runtime constraints
   (language preference, hosting target), data ownership (one app, or multiple
   services from day one?), auth needs, deadline pressure.
2. **Architect decision** — output the standard contract from
   `.kpl/agents/rules/architecture-mentor.md`:
   - **Pattern:** starting structure (e.g. "single app, layered by feature" / "modular monolith")
   - **Why here:** tied to the answers above, not to trends
   - **Tradeoff:** what this costs later
   - **Not doing:** microservices / CQRS / premature abstractions, named explicitly
   - Prefer the **boring** option from `.kpl/agents/rules/pragmatic-ladder.md`. Only propose a second option if the boring one is clearly wrong for a stated constraint.
3. Install the control plane into the target the same way `kpl-sdd-init` does (reuse that skill's install steps), then:
   - Fill `.kpl/specs/stack.md` from the interview (mark items `planned` vs `installed` since nothing is installed yet).
   - Write `.kpl/memory/cards/adr-initial-architecture.md` from `_template-adr.md` capturing the Step 2 decision; add a row to `.kpl/memory/INDEX.md`.
   - Write `.kpl/specs/features/_bootstrap/README.md`: project name, date, the architecture decision summary, and a link to the ADR.
4. Tell the user the next skill is `feature-discovery` for the first real feature (or `sdd-onboard` if they want a guided walkthrough first).

## Rules

- Do not scaffold application code here — this skill decides structure and memory, not `src/`. Hand off actual scaffolding (folders, `package.json`, etc.) to the normal implement flow once a feature or chore package exists, unless the user explicitly asks for a minimal runnable skeleton as the first `chore/` package.
- Never pick a framework "because it's popular" without tying it to an answer from the interview.
- One ADR here is enough; don't fragment the first decision across multiple cards.
