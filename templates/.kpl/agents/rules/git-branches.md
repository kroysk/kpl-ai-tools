# Git branches

Never develop on `main`/`master`.

| Type | Prefix | Example |
| --- | --- | --- |
| Feature | `feature/` | `feature/checkout` |
| Fix | `fix/` | `fix/null-guard` |
| Deps/tech | `chore/` | `chore/upgrade-vite` |

Same slug across multi-package work. Create branch before first code change. Publish pushes the working branch (no force; no silent merge to main).
