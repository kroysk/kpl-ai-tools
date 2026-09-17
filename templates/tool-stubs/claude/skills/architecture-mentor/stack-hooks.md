# Stack hooks (fill after explore)

Do **not** invent a stack. After `kpl-project-explore` / `kpl-sdd-init`, copy facts from `specs/stack.md` into the table below (in the **target** project’s copy of this file, or a memory card).

## Project facts

| Hook | Value (from stack.md / CONTROL_PLANE) |
| --- | --- |
| Languages / runtimes | |
| App packages (api, web, …) | |
| Framework conventions (modules, folders) | |
| Persistence | |
| Auth model | |
| Deploy / jobs | |
| Test command(s) | |

## How to specialize mentoring

1. Prefer patterns that already exist in **this** repo (grep sibling features).
2. Map “feature module” to the real folder convention (e.g. `apps/api/src/modules/…`).
3. Map “ports at trust boundary” to the real middleware / guards / form validation layer.
4. Name concrete file paths in the Architecture note **Files / boundaries** line.
5. If stack is still empty: stay agnostic; ask user to approve explore/init fill of `specs/stack.md` first.

## Optional memory

Persistent stack decisions → `memory/cards/adr-<slug>.md` + INDEX row.
