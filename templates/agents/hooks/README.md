# Token I/O hooks

Canon scripts for Cursor and Claude Code. Init merges them into each tool’s config (does not replace user settings).

- `kpl-check-read.ps1` — Windows
- `kpl-check-read.sh` — Linux / macOS

Policy: `../io-policy.json`. Disable enforce: `KPL_READ_MIN_LINES=0`. Fail-open.

OpenCode uses `.opencode/plugins/kpl-bulk-read.js` (auto-load; no `opencode.json` change). First tool call of an OpenCode session may skip the plugin (upstream); skill `bulk-read` is the fallback.
