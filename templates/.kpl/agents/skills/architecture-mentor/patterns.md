# Pattern catalog (agnostic)

Use only when Decide / Review needs a named option. Prefer the left column’s “when not”.

| Pattern | When | When not |
| --- | --- | --- |
| **Direct / none** | Local change; one module already owns the concern | Cross-cutting auth, multi-writer data, new public API surface |
| **Feature module** | Cohesive feature with clear UI+domain folder or package | Splitting by technical layer only (“controllers vs services”) with no boundary |
| **Ports at trust boundary** | External IO, auth, payments, user input → validate at edge | Wrapping every stdlib call in an interface “for SOLID” |
| **Repository / data access** | Multiple query shapes, swap persistence, or test isolation needed | Single CRUD through framework ORM with no second path |
| **Modular monolith** | Clear domains, one deployable; enforce module edges | Fake modules that freely import each other’s internals |
| **BFF** | UI needs aggregation/shape different from public API | Same shape as API and only one client |
| **Strangler** | Replacing legacy piece-by-piece behind a facade | Greenfield; or big-bang rewrite without a seam |
| **Outbox / reliable events** | Must not lose side effects after commit | Simple in-process call; no multi-system consistency need |
| **CQRS / split models** | Read and write models diverge hard; proven pain | Default CRUD; early speculative “scale” |

## Decision bias

1. Reuse existing structure in this repo.
2. Smallest seam that contains the change.
3. Name the pattern only if it changes how someone else should extend the code.
