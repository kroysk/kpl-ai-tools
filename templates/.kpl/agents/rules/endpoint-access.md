# Endpoint / route access

Every HTTP endpoint in plans/PRDs/specs/contract must declare:

- `access: public` or  
- `access: permission:<code>` (or project-equivalent authz)

Never leave auth TBD. Frontends may hide UI from the same matrix; **server enforces**. Adapt role names to the project (document in contract).
