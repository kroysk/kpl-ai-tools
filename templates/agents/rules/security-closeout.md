# Security closeout

When all `T-*` for an API-touching (or trust-boundary) feature are `done`, write `security-review.md` from `specs/_templates/security-review.md`.

Require **Scope** + findings with kind (`confirmed` | `needs_validation` | `hardening`) and evidence `path:line`. Defensive remediations only — **no** exploits/PoCs.

Severity only on `confirmed`; must not exceed demonstrated impact. Open confirmed critical/high → remediation `T-*` with a concrete file. `fail` only if those lack a task. `needs_validation` is neither silent pass nor automatic fail.
