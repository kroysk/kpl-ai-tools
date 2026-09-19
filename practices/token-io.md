# Token I/O

Frontier models should spend tokens on judgment, not on moving whole files.

- **I/O (delegate):** understand a large file or package; extract names, types, line facts
- **Judgment (never delegate):** edits, debugging, architecture, security closeout

Default threshold: **500 lines** (`agents/io-policy.json`). Override with `KPL_READ_MIN_LINES`. Set `0` to disable hook enforce.

Prefer `Grep` / `Glob`, then `Read` with `offset`/`limit`. If a hook blocks a full `Read`, load skill `bulk-read`. After a summary, read the exact span before editing.

Hooks fail **open** (a broken hook must not stop implement). Known gap: first OpenCode tool call in a session may skip the plugin; the skill is the fallback. `python -c open()` and similar bypasses are out of scope for v1.
