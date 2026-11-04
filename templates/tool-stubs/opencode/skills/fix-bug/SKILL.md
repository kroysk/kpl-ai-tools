---
name: fix-bug
description: >-
  Starts a defect fix with discovery.md (root cause required) under
  .kpl/specs/features/<id>/kind:fix — same formal cycle as a feature (discovery →
  PRD → spec → branch → implement → closeout) but branch prefix fix/ and a
  mandatory root-cause section. Use when: bug, defect, broken, regression,
  something is wrong, fix path. Not for: new capability/actor/route/trust
  boundary (use feature-discovery instead) or a question (use bulk-read).
---

# fix-bug

Bugs get the **same rigor** as features — discovery, PRD, spec, human gates — only
the branch prefix and the extra root-cause field differ. Diff size never decides
the path; **scope** does. See `.kpl/agents/rules/sdd-cycle.md`.

## Preconditions

- Control plane present (`AGENTS.md`, `.kpl/specs/`).
- User describes a defect (something that should work and does not).

## Step 0 — Architect gate (always)

Before opening discovery, the architecture mentor answers one question out loud:

> **Does fixing this require a new capability, actor, route, or trust boundary?**

- **No** → this is a real fix. Continue below.
- **Yes** → this is a feature wearing a bug report. Stop; hand off to `feature-discovery`.

State the call briefly: *Pattern: fix vs feature — Why: <1 sentence> — Not doing: full discovery cycle (unless redirected).*

## Steps

1. Propose `id` slug (kebab-case, verb-first ok, e.g. `fix-null-session-token`) and path `.kpl/specs/features/<id>/`.
2. Create `discovery.md` from `.kpl/specs/_templates/discovery.md` with `kind: fix`.
3. Fill the usual fields **plus** `Root cause`: repro steps, exact defect location (file:line if known), why it happens (not just what).
4. Mark `awaiting_approval`. Stop for human approval — same gate as a feature.
5. After approval: `write-prd` (`kind: fix`) → `write-feature-spec` → `git-branch` with **`fix/`** prefix (never `feature/`) → `implement-from-spec`.
6. Security closeout (`security-review-api` / `-front`) only if the defect or fix touches an API, auth, or a trust boundary — otherwise note "N/A, no boundary touched" in `tasks.md`.
7. `publish-feature` as usual.

## Architect note during implement

Even a one-line patch gets the brief contract (`.kpl/agents/rules/architecture-mentor.md`):
Pattern (e.g. "guard clause" / "null check" / "revert bad assumption") / Why here /
Tradeoff / Not doing. Ask once if the user wants it expanded — do not lecture by default.

## Output

- File: `.kpl/specs/features/<id>/discovery.md` (`kind: fix`)
- Tell user: approve discovery → next skill `write-prd`.

## Rules

- One defect per package. If a second bug surfaces, open a new `id`.
- Regression test or manual verification step required in `tasks.md` before Closed PASS.
- Never skip the human approval gates to "save time" — that is what turns a fix into a silent feature.
