---
name: security-review-front
description: >-
  Defensive front-end security review for UI features: XSS/CSP mindset, secret
  leakage, authz hide vs enforce. Use when: front security review, UI closeout,
  XSS, client secrets. Not for: exploit PoCs or replacing server-side security-review-api.
---

# security-review-front

## Preconditions

- Feature has UI; prefer after implement. Pair with `security-review-api` if API also changed.
- Template: `specs/_templates/security-review.md`.

## Steps

1. Seed **Scope** from AC / designer brief + changed client surfaces (HTML sinks, authz UI, cookies).
2. If `security-review.md` already exists, revalidate any `S-*` whose evidence paths changed; do not rewrite blindly.
3. Append or write findings into `specs/features/<id>/security-review.md` (same template table) with area `front`.
4. Check: no secrets in client bundles; dangerous HTML sinks; authz UI hide ≠ server enforce; CSRF/cookie patterns as stack requires.
5. For each `confirmed` critical/high: re-read cited `path:line` and try to disprove (other control? hardening?). Downgrade if it does not hold.
6. Open critical/high confirmed → remediation `T-*` with a concrete file. Defensive remediations only — **no** exploit write-ups.

## Verdict

Contribute to overall verdict; `fail` only if confirmed critical/high front issues lack remediation tasks.
