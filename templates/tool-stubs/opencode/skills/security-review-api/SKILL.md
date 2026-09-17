---
name: security-review-api
description: >-
  Defensive API security closeout: writes security-review.md with S-001… findings
  and remediations only — no exploits or PoCs. Use when: API tasks done, security
  review, closeout, security-review.md. Not for: offensive testing, exploit write-ups,
  or UI-only reviews (use security-review-front).
---

# security-review-api

## Preconditions

- Feature touched HTTP/API or trust boundary; prefer all related `T-*` done.
- Template: `specs/_templates/security-review.md`.
- Rule: `agents/rules/security-closeout.md`.

## Steps

1. Skim PRD/spec endpoints + access matrix + changed API files.
2. Write `specs/features/<id>/security-review.md`:
   - Table `S-001…`: severity | area | finding | remediation | status
   - Verdict: `pass` | `pass_with_findings` | `fail`
3. Open critical/high → new remediation tasks in `tasks.md` (do not silently pass).
4. **Defensive only** — describe how to harden; never provide exploit steps, payloads, or attack scripts.

## Focus areas (checklist, not exploits)

Authn/z on every route, input validation, injection classes at data edge, secrets handling, error leakage, IDOR / object-level auth, rate limits if relevant to stack.
