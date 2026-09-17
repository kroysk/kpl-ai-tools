---
name: sdd-quality-gate
description: >-
  Checks Definition of Ready / Done for discovery, PRD, specs, or closeout before
  human approval. Use when: quality gate, ready check, before approve, gate PASS.
  Not for: writing the documents themselves or implementing code.
---

# sdd-quality-gate

## Stages

### → PRD (discovery)

- [ ] Primary goal clear; Done when testable
- [ ] Access declared if HTTP (no TBD)
- [ ] Open questions ≤5 or resolved
- [ ] Human approved

### → Specs (PRD)

- [ ] PRD approved; FR ≤8; AC binary mapped to FR
- [ ] Endpoints have access if HTTP
- [ ] Spec plan present

### → Code (specs)

- [ ] Specs ready; `tasks.md` with T-001…
- [ ] Architecture section filled when design non-trivial
- [ ] Branch plan ≠ main
- [ ] Designer brief/mockups if UI required by AC

### → Closed

- [ ] T-* done or explicitly deferred
- [ ] `security-review.md` if API touched; critical/high remediated or tasked
- [ ] `publish.md` optional

## Output

List FAIL items first; then PASS summary. Do not mark approved yourself — human does.
