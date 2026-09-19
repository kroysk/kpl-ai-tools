#!/usr/bin/env bash
# Merge KPL token-I/O hooks into a target without replacing user hook/settings files.
# Usage: scripts/merge-kpl-io-hooks.sh [target-dir]

set -euo pipefail

TARGET="${1:-.}"
TARGET="$(cd "$TARGET" && pwd)"

if [[ "$(uname -s)" == "MINGW"* || "$(uname -s)" == "MSYS"* || "$(uname -s)" == "CYGWIN"* ]]; then
  HOOK_CMD="powershell -NoProfile -ExecutionPolicy Bypass -File agents/hooks/kpl-check-read.ps1"
else
  HOOK_CMD="sh agents/hooks/kpl-check-read.sh"
fi

merge_py() {
  python3 - "$TARGET" "$HOOK_CMD" <<'PY'
import json, os, sys

target, hook_cmd = sys.argv[1], sys.argv[2]

def is_kpl(entry):
    if not isinstance(entry, dict):
        return False
    if "kpl-check-read" in str(entry.get("command", "")):
        return True
    for h in entry.get("hooks") or []:
        if isinstance(h, dict) and "kpl-check-read" in str(h.get("command", "")):
            return True
    return False

def drop_kpl(items):
    return [x for x in (items or []) if not is_kpl(x)]

def load(path):
    if not os.path.isfile(path):
        return None
    try:
        with open(path, encoding="utf-8") as f:
            raw = f.read().strip()
        return json.loads(raw) if raw else None
    except json.JSONDecodeError:
        print(f"warning: skip invalid JSON {path}", file=sys.stderr)
        raise

def dump(path, obj):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(obj, f, indent=2)
        f.write("\n")

# Cursor
cpath = os.path.join(target, ".cursor", "hooks.json")
try:
    cursor = load(cpath)
except json.JSONDecodeError:
    cursor = False
if cursor is not False:
    if not cursor:
        cursor = {"version": 1, "hooks": {}}
    hooks = cursor.setdefault("hooks", {})
    hooks["preToolUse"] = drop_kpl(hooks.get("preToolUse")) + [
        {"command": hook_cmd, "matcher": "Read"}
    ]
    hooks["beforeReadFile"] = drop_kpl(hooks.get("beforeReadFile")) + [
        {"command": hook_cmd}
    ]
    hooks["beforeShellExecution"] = drop_kpl(hooks.get("beforeShellExecution")) + [
        {"command": hook_cmd}
    ]
    cursor.setdefault("version", 1)
    dump(cpath, cursor)

frag = os.path.join(target, ".cursor", "kpl-hooks.json")
if os.path.isfile(frag):
    os.remove(frag)

# Claude
spath = os.path.join(target, ".claude", "settings.json")
try:
    claude = load(spath)
except json.JSONDecodeError:
    claude = False
if claude is not False:
    if not claude:
        claude = {}
    hooks = claude.setdefault("hooks", {})
    pre = drop_kpl(hooks.get("PreToolUse"))
    pre.append({"matcher": "Read", "hooks": [{"type": "command", "command": hook_cmd}]})
    pre.append({"matcher": "Bash", "hooks": [{"type": "command", "command": hook_cmd}]})
    hooks["PreToolUse"] = pre
    dump(spath, claude)

frag = os.path.join(target, ".claude", "kpl-hooks.json")
if os.path.isfile(frag):
    os.remove(frag)

print(f"Merged KPL token-I/O hooks into {target}")
print(f"  hook command: {hook_cmd}")
PY
}

if command -v python3 >/dev/null 2>&1; then
  merge_py
else
  echo "warning: python3 not found; wrote hook scripts but did not merge JSON configs" >&2
  echo "  run later: python3 $0 $TARGET   (or scripts/merge-kpl-io-hooks.ps1)" >&2
fi
