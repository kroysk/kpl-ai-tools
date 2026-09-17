#!/usr/bin/env bash
# Install Kephale AI Toolkit (kpl-ai-tools) SDD control plane into a project.
# Linux / macOS. Merge-safe: never deletes specs/features/**; does not touch src/ app/.
#
# Usage:
#   ./scripts/install.sh [target-dir]
#   curl -fsSL https://raw.githubusercontent.com/kroysk/kpl-ai-tools/main/scripts/install.sh | bash
#   curl -fsSL ... | bash -s -- /path/to/project
#
# Env:
#   KPL_REPO_URL  Git URL (default: https://github.com/kroysk/kpl-ai-tools.git)
#   KPL_REF       Branch or tag (default: main)

set -euo pipefail

KPL_REPO_URL="${KPL_REPO_URL:-https://github.com/kroysk/kpl-ai-tools.git}"
KPL_REF="${KPL_REF:-main}"
TARGET="${1:-.}"

die() { echo "error: $*" >&2; exit 1; }

need_cmd() { command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"; }

resolve_kit_root() {
  local here
  if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    if [[ -d "$here/templates/agents" && -d "$here/templates/tool-stubs" ]]; then
      echo "$here"
      return 0
    fi
  fi
  return 1
}

copy_tree() {
  local src="$1" dest="$2"
  mkdir -p "$dest"
  # Prefer rsync; fall back to cp -R
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$src"/ "$dest"/
  else
    cp -R "$src"/. "$dest"/
  fi
}

merge_dir() {
  # Copy files from src into dest; do not delete extras in dest.
  local src="$1" dest="$2"
  mkdir -p "$dest"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$src"/ "$dest"/
  else
    (
      cd "$src" && tar cf - .
    ) | (
      cd "$dest" && tar xf -
    )
  fi
}

echo "==> Kephale AI Toolkit install"
echo "    repo: $KPL_REPO_URL @ $KPL_REF"
echo "    target: $TARGET"

need_cmd git
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

KIT_ROOT=""
CLEANUP=""
if KIT_ROOT="$(resolve_kit_root)"; then
  echo "    kit: local $KIT_ROOT"
else
  need_cmd mktemp
  CLEANUP="$(mktemp -d "${TMPDIR:-/tmp}/kpl-ai-tools.XXXXXX")"
  echo "    kit: cloning into $CLEANUP"
  git clone --depth 1 --branch "$KPL_REF" "$KPL_REPO_URL" "$CLEANUP/kpl-ai-tools"
  KIT_ROOT="$CLEANUP/kpl-ai-tools"
fi

TEMPLATES="$KIT_ROOT/templates"
[[ -d "$TEMPLATES/agents" ]] || die "templates missing in kit: $TEMPLATES"

# Root entry docs
cp -f "$TEMPLATES/AGENTS.md" "$TARGET/AGENTS.md"
cp -f "$TEMPLATES/CLAUDE.md" "$TARGET/CLAUDE.md"

# agents / specs / memory (merge; never wipe features)
merge_dir "$TEMPLATES/agents" "$TARGET/agents"
mkdir -p "$TARGET/specs"
# Copy specs pieces without deleting features/
for item in README.md SKILLS.md stack.md; do
  [[ -f "$TEMPLATES/specs/$item" ]] && cp -f "$TEMPLATES/specs/$item" "$TARGET/specs/$item"
done
merge_dir "$TEMPLATES/specs/contract" "$TARGET/specs/contract"
merge_dir "$TEMPLATES/specs/_templates" "$TARGET/specs/_templates"
mkdir -p "$TARGET/specs/features/_bootstrap"
if [[ -f "$TEMPLATES/specs/features/_bootstrap/README.md" ]]; then
  if [[ ! -f "$TARGET/specs/features/_bootstrap/README.md" ]]; then
    cp -f "$TEMPLATES/specs/features/_bootstrap/README.md" "$TARGET/specs/features/_bootstrap/README.md"
  fi
fi
DATE="$(date +%Y-%m-%d)"
{
  echo "# Bootstrap"
  echo
  echo "Installed by Kephale AI Toolkit scripts/install.sh on $DATE"
  echo
  echo "Source: $KPL_REPO_URL @ $KPL_REF"
} >"$TARGET/specs/features/_bootstrap/README.md"

merge_dir "$TEMPLATES/memory" "$TARGET/memory"

# Tool packs
merge_dir "$TEMPLATES/tool-stubs/cursor" "$TARGET/.cursor"
merge_dir "$TEMPLATES/tool-stubs/claude" "$TARGET/.claude"
mkdir -p "$TARGET/.opencode"
merge_dir "$TEMPLATES/tool-stubs/opencode/skills" "$TARGET/.opencode/skills"
if [[ -f "$TEMPLATES/tool-stubs/opencode/opencode.json" && ! -f "$TARGET/.opencode/opencode.json" ]]; then
  cp -f "$TEMPLATES/tool-stubs/opencode/opencode.json" "$TARGET/.opencode/opencode.json"
fi

# Optional practices reference
if [[ -d "$KIT_ROOT/practices" ]]; then
  merge_dir "$KIT_ROOT/practices" "$TARGET/agents/practices"
fi

if [[ -n "$CLEANUP" ]]; then
  rm -rf "$CLEANUP"
fi

echo
echo "Done. Control plane installed at:"
echo "  $TARGET"
echo
echo "Next:"
echo "  1. Open this project in Cursor / Claude Code / OpenCode"
echo "  2. Fill specs/stack.md for your stack"
echo "  3. Start with skill: feature-discovery"
echo
echo "Did not modify application source (src/, app/, etc.)."
