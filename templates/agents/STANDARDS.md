# Standards — Clean Code + SOLID

Always apply with the pragmatic ladder (`agents/rules/pragmatic-ladder.md`).

## Clean Code

- Names reveal intent; small functions; one abstraction level
- Prefer expressive code over narrating comments
- DRY with judgment — no premature abstractions
- Fail fast at trust boundaries; don't swallow errors that lose data

## SOLID (definitions)

| | Name | Principle |
| --- | --- | --- |
| **S** | Single Responsibility | A module/class has **one reason to change** (one responsibility). |
| **O** | Open/Closed | **Open for extension**, closed for modification — add behavior without rewriting stable code. |
| **L** | Liskov Substitution | Subtypes must be **substitutable** for their base type without breaking contracts (pre/postconditions, invariants). |
| **I** | Interface Segregation | Prefer **small, specific interfaces**; clients must not depend on methods they do not use. |
| **D** | Dependency Inversion | High-level modules must not depend on low-level details; both depend on **abstractions**. Abstractions must not depend on details. |

### Applying (not a redefinition)

- Thin handlers / focused UI units (SRP)
- Extend via new types/strategies, don't endlessly edit stable cores (OCP)
- Substitutable subtypes without breaking contracts (LSP)
- Small interfaces; no unused forced methods (ISP)
- High level depends on abstractions, not details (DIP)

Full practice text also in kit `practices/clean-solid.md` when regenerating from kpl-ai-tools.
