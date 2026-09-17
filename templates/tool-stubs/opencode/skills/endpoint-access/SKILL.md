---
name: endpoint-access
description: >-
  Ensures every HTTP route declares access public or permission:<code>; keeps
  specs/contract and server enforcement aligned. Use when: new endpoint, route
  access, permission matrix, authz on API, contract table.
  Not for: UI-only hide/show without server check, or leaving auth TBD.
---

# endpoint-access

## Rules

Follow `agents/rules/endpoint-access.md`.

Every HTTP endpoint in PRD/specs/contract:

- `access: public` **or**
- `access: permission:<code>` (project-equivalent authz)

Server **enforces**. Frontend may hide from the same matrix; hide ≠ security.

## Steps

1. List new/changed routes for the feature.
2. Assign access; update PRD/spec Endpoints and `specs/contract/README.md` table if used.
3. Confirm implementation checks authz where data lives.
4. If permission codes unknown: ask user or document gap — never leave TBD silently.

## Output

Short table: method + path + access. Flag any route missing enforcement.
