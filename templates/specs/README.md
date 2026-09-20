# Specs — product memory

## Cycle

Discover → PRD → specs+tasks → designer brief → mockups → branch → implement → security → publish

## Package

`specs/features/<id>/` — discovery, prd, spec-*, tasks, designer-brief, mockups/, security-review, publish.md

## Definition of ready

- → PRD: goal, Done when, access if HTTP, gate PASS, approved
- → Specs: PRD approved, FR/AC, tasks.md
- → Code: ready specs + branch ≠ main
- → Closed: T-* done + security-review (Scope + evidence) when API/trust boundary touched + publish optional
