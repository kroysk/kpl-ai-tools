---
name: bulk-read
description: >-
  Answers one question about large files via Grep and targeted reads
  instead of loading whole files into the frontier model. Use when:
  understanding a file or package over the line threshold without editing yet.
  Not for: patches, debugging, architecture decisions, or security closeout.
---

# bulk-read

Follow `agents/rules/token-io.md`. Threshold: `agents/io-policy.json` (default 500; `KPL_READ_MIN_LINES`, `0` disables hooks).

## Preconditions

- One concrete question (not “read everything”).
- You are **not** about to patch, debug, decide architecture, or do a security review from the summary alone.

## Steps

1. State the question in one sentence.
2. Do **not** `Read` the whole file. `Grep` / `Glob` first; `Read` only with `offset`/`limit`.
3. Multi-file corpus: use the tool’s explore/subagent if available; you still return the bullets — do not paste source.
4. Reply with bullets only: `name | type | line | fact`. No preamble.
5. If the next step is an **edit**, `Read` that span with `offset`/`limit` before changing anything. Summaries are not a substitute for the source.

## Hard rules

- One question per pass. Follow-ups are a new pass (re-scan; do not assume the old summary is complete).
- Never write or patch from bullets alone.
- Debugging, architecture-mentor, and security closeout stay on the frontier model with targeted reads.
