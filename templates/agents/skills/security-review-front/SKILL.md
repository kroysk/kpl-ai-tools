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

## Steps

1. Review client surfaces against AC / designer brief.
2. Append or write findings into `specs/features/<id>/security-review.md` (same S-001… table) with area `front`.
3. Check: no secrets in client bundles; dangerous HTML sinks; authz UI hide ≠ server enforce; CSRF/cookie patterns as stack requires.
4. Defensive remediations only — **no** exploit write-ups.

## Verdict

Contribute to overall verdict; fail if critical front issues open without tasks.
