#!/usr/bin/env bash
# Read-only health check for a KPL control plane in a target project.
# Usage: scripts/kpl-doctor.sh [target-dir]
# Exit 0 if no FAIL (WARN allowed). Exit 1 if any FAIL. Writes nothing to the target.

set -euo pipefail

TARGET="${1:-.}"
TARGET="$(cd "$TARGET" && pwd)"

FAILS=0
WARNS=0

fail() { echo "FAIL  $*" >&2; FAILS=$((FAILS + 1)); }
warn() { echo "WARN  $*" >&2; WARNS=$((WARNS + 1)); }

echo "==> kpl-doctor"
echo "    target: $TARGET"
echo

# kpl-kit.json
KIT_JSON="$TARGET/agents/kpl-kit.json"
if [[ ! -f "$KIT_JSON" ]]; then
  fail "missing agents/kpl-kit.json"
else
  for field in kit repo ref installedAt; do
    if ! grep -q "\"$field\"" "$KIT_JSON"; then
      fail "agents/kpl-kit.json missing or empty field: $field"
    fi
  done
fi

[[ -f "$TARGET/AGENTS.md" ]] || fail "missing AGENTS.md"
[[ -d "$TARGET/agents" ]] || fail "missing agents/"
[[ -f "$TARGET/specs/SKILLS.md" ]] || fail "missing specs/SKILLS.md"
[[ -f "$TARGET/memory/INDEX.md" ]] || fail "missing memory/INDEX.md"

if [[ ! -f "$TARGET/specs/stack.md" ]]; then
  fail "missing specs/stack.md"
else
  if grep -qiE 'Filled by.?kpl-sdd-init|^# Stack$' "$TARGET/specs/stack.md" 2>/dev/null; then
    # Heuristic: short/template-like content
    lines="$(wc -l <"$TARGET/specs/stack.md" | tr -d ' ')"
    if [[ "$lines" -lt 5 ]] || grep -qi 'Filled by' "$TARGET/specs/stack.md"; then
      warn "specs/stack.md still looks like the unfilled template"
    fi
  fi
fi

if [[ -f "$TARGET/specs/SKILLS.md" ]]; then
  while IFS= read -r name; do
    [[ -z "$name" || "$name" == "Skill" || "$name" =~ ^-+$ ]] && continue
    if [[ ! -f "$TARGET/agents/skills/$name/SKILL.md" ]]; then
      fail "skill listed in SKILLS.md but missing: agents/skills/$name/SKILL.md"
    fi
  done < <(awk -F'|' '/^\|[[:space:]]*[a-z0-9-]+[[:space:]]*\|/ { gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2 }' "$TARGET/specs/SKILLS.md")
fi

if [[ -d "$TARGET/.cursor" ]]; then
  if [[ ! -f "$TARGET/.cursor/hooks.json" ]]; then
    fail ".cursor/ present but hooks.json missing"
  elif ! grep -q 'kpl-check-read' "$TARGET/.cursor/hooks.json"; then
    fail ".cursor/hooks.json missing kpl-check-read"
  fi
fi

if [[ -d "$TARGET/.claude" ]]; then
  if [[ ! -f "$TARGET/.claude/settings.json" ]]; then
    fail ".claude/ present but settings.json missing"
  elif ! grep -q 'kpl-check-read' "$TARGET/.claude/settings.json"; then
    fail ".claude/settings.json missing kpl-check-read"
  fi
fi

if [[ -d "$TARGET/.opencode" ]]; then
  if [[ ! -f "$TARGET/.opencode/plugins/kpl-bulk-read.js" ]]; then
    fail ".opencode/ present but plugins/kpl-bulk-read.js missing"
  fi
fi

if [[ -f "$TARGET/AGENTS.md" ]]; then
  if ! grep -q 'kpl:user:start' "$TARGET/AGENTS.md" || ! grep -q 'kpl:user:end' "$TARGET/AGENTS.md"; then
    fail "AGENTS.md missing kpl:user markers"
  fi
fi

echo
if [[ "$FAILS" -eq 0 && "$WARNS" -eq 0 ]]; then
  echo "PASS  control plane looks healthy"
elif [[ "$FAILS" -eq 0 ]]; then
  echo "PASS with WARN ($WARNS)"
else
  echo "FAILED ($FAILS fail, $WARNS warn)" >&2
fi

[[ "$FAILS" -gt 0 ]] && exit 1
exit 0
