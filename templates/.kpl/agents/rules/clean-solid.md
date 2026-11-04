# Clean Code + SOLID

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

- Keep handlers/controllers/UI units thin; one responsibility per type (SRP)
- Extend with new types/strategies instead of endlessly editing a core switch (OCP)
- Don't weaken base guarantees in subtypes or drop-in replacements (LSP)
- Narrow APIs — avoid god interfaces (ISP)
- Depend on ports/abstractions at boundaries; wire details inward (DIP)
- Climb the pragmatic ladder before adding layers
