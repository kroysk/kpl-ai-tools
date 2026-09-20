# Security review → `security-review.md`

Defensive only — remediations, never exploits/PoCs/payloads.

```markdown
---
id: <feature-slug>
source_ref: <commit-sha or dirty>
verdict: pass | pass_with_findings | fail
---

# Security review

## Scope
- Surfaces reviewed: (routes / jobs / webhooks / UI sinks / …)
- Out of scope: …
- Seeded from: endpoint-access matrix + changed feature files

## Findings

| ID | kind | severity | area | boundary | evidence | finding | smallest fix | status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S-001 | confirmed | high | api | … | path:line | … | … | open → T-00N |

### Kind
- `confirmed` — control crossed in source; **has** severity
- `needs_validation` — source-grounded hypothesis blocked by deploy/runtime fact; **no** severity; name the exact blocker
- `hardening` — missing extra layer, but another control already closes the boundary; not a vuln

### Severity (confirmed only)
critical / high / medium / low / info — must not exceed demonstrated impact
(bypass, cross-tenant, secret exposure). Checklist gaps are not high.

### Verdict
- `pass` — no open confirmed issues (hardening / needs_validation OK to list)
- `pass_with_findings` — open medium/low/info or tasked work in progress
- `fail` — only if confirmed critical/high lacks a remediation `T-*` (or is not done)
```
