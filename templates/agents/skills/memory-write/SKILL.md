---
name: memory-write
description: >-
  Writes a dense memory card and updates memory/INDEX.md after a lasting lesson
  or ADR. Use when: save lesson, memory card, ADR, remember this practice.
  Not for: dumping full specs, long essays, or more than needed for INDEX.
---

# memory-write

## Protocol

Follow `agents/rules/memory-protocol.md`: skim INDEX; future tasks open **max 1–2** cards.

## Steps

1. Decide card type:
   - Practice lesson → `memory/cards/<slug>.md` (When / Anti / bullets)
   - Architecture decision → copy `memory/cards/_template-adr.md` → `adr-<slug>.md`
2. Keep the card **dense** (short bullets, no essays).
3. Add one row to `memory/INDEX.md` with When trigger.
4. Do not paste the full card into every later chat — INDEX is the pointer.

## Anti-patterns

- Loading entire `specs/` as “memory”
- Duplicate cards for the same lesson
