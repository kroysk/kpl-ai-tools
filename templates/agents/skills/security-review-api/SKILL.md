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

1. Seed **Scope** from the endpoint-access matrix + changed API/trust-boundary files for this feature. If the feature touches LLM/tools/MCP, include that boundary in Scope.
2. If `security-review.md` already exists, revalidate any `S-*` whose evidence paths changed; do not rewrite blindly.
3. Write/update `specs/features/<id>/security-review.md` from the template:
   - Scope (surfaces, out of scope, source_ref)
   - Table `S-001…`: kind | severity | area | boundary | evidence (`path:line`) | finding | smallest fix | status
   - Verdict: `pass` | `pass_with_findings` | `fail`
4. For each `confirmed` critical/high: re-read cited `path:line` and try to disprove (other control? really hardening?). Downgrade if it does not hold.
5. Open critical/high confirmed → new remediation `T-*` in `tasks.md` with a concrete file (do not silently pass).
6. **Defensive only** — describe what the code allows and how to harden; never provide exploit steps, payloads, or attack scripts.

## Focus areas (checklist, not exploits)

Authn/z on every route, input validation, injection classes at data edge, secrets handling, error leakage, IDOR / object-level auth, rate limits if relevant to stack.

## Anti-patterns

- Checklist deviation ≠ vulnerability; severity requires demonstrated impact.
- Do not guess deploy/CDN/IdP behavior → `needs_validation` with exact blocker.
- UI hide ≠ server enforce.
- `fail` only when confirmed critical/high lacks a remediation task.
