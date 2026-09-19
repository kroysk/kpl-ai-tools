#!/usr/bin/env bash
# Install Kephale AI Toolkit (kpl-ai-tools) SDD control plane into a project.
# Linux / macOS. Merge-safe: never deletes specs/features/**; does not touch src/ app/.
#
# Usage:
#   ./scripts/install.sh [target-dir]
#   ./scripts/install.sh --refresh [target-dir]
#   curl -fsSL https://raw.githubusercontent.com/kroysk/kpl-ai-tools/main/scripts/install.sh | bash
#   curl -fsSL ... | bash -s -- /path/to/project
#   curl -fsSL ... | bash -s -- --refresh /path/to/project
#
# Env:
#   KPL_REPO_URL  Git URL (default: https://github.com/kroysk/kpl-ai-tools.git)
#   KPL_REF       Branch or tag (default: main)

set -euo pipefail

KPL_REPO_URL="${KPL_REPO_URL:-https://github.com/kroysk/kpl-ai-tools.git}"
KPL_REF="${KPL_REF:-main}"
REFRESH=0
TARGET="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --refresh|-r)
      REFRESH=1
      shift
      ;;
    -*)
      echo "error: unknown flag: $1" >&2
      exit 1
      ;;
    *)
      TARGET="$1"
      shift
      ;;
  esac
done

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

copy_if_missing() {
  local src="$1" dest="$2"
  [[ -f "$dest" ]] && return 0
  mkdir -p "$(dirname "$dest")"
  cp -f "$src" "$dest"
}

backup_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    cat "$path"
  fi
}

restore_file() {
  local path="$1"
  local content="$2"
  [[ -z "$content" ]] && return 0
  mkdir -p "$(dirname "$path")"
  printf '%s' "$content" >"$path"
}

merge_memory_refresh() {
  local src="$1" dest="$2"
  mkdir -p "$dest/cards"
  if [[ -f "$src/INDEX.md" && ! -f "$dest/INDEX.md" ]]; then
    cp -f "$src/INDEX.md" "$dest/INDEX.md"
  fi
  if [[ -f "$src/cards/_template-adr.md" && ! -f "$dest/cards/_template-adr.md" ]]; then
    cp -f "$src/cards/_template-adr.md" "$dest/cards/_template-adr.md"
  fi
}

merge_cursor_refresh() {
  local src="$1" dest="$2"
  if [[ -d "$src/skills" ]]; then
    merge_dir "$src/skills" "$dest/skills"
  fi
  if [[ -d "$src/rules" ]]; then
    mkdir -p "$dest/rules"
    # shellcheck disable=SC2044
    for f in "$src/rules"/*.mdc; do
      [[ -f "$f" ]] || continue
      cp -f "$f" "$dest/rules/$(basename "$f")"
    done
  fi
}

merge_claude_refresh() {
  local src="$1" dest="$2"
  if [[ -d "$src/skills" ]]; then
    merge_dir "$src/skills" "$dest/skills"
  fi
}

MODE="install"
[[ "$REFRESH" -eq 1 ]] && MODE="refresh"

echo "==> Kephale AI Toolkit $MODE"
echo "    repo: $KPL_REPO_URL @ $KPL_REF"
echo "    target: $TARGET"
[[ "$REFRESH" -eq 1 ]] && echo "    mode: refresh (preserve stack/CONTROL_PLANE/features/memory cards)"

need_cmd git
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

if [[ "$REFRESH" -eq 1 ]]; then
  [[ -f "$TARGET/AGENTS.md" && -d "$TARGET/agents" ]] || die "Refresh requires an existing control plane (AGENTS.md + agents/). Use install without --refresh for first-time setup."
fi

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

BAK_CONTROL=""
BAK_HOOK_AGENTS=""
BAK_HOOK_CURSOR=""
BAK_HOOK_CLAUDE=""
BAK_HOOK_OPENCODE=""
if [[ "$REFRESH" -eq 1 ]]; then
  BAK_CONTROL="$(backup_file "$TARGET/agents/CONTROL_PLANE.md" || true)"
  BAK_HOOK_AGENTS="$(backup_file "$TARGET/agents/skills/architecture-mentor/stack-hooks.md" || true)"
  BAK_HOOK_CURSOR="$(backup_file "$TARGET/.cursor/skills/architecture-mentor/stack-hooks.md" || true)"
  BAK_HOOK_CLAUDE="$(backup_file "$TARGET/.claude/skills/architecture-mentor/stack-hooks.md" || true)"
  BAK_HOOK_OPENCODE="$(backup_file "$TARGET/.opencode/skills/architecture-mentor/stack-hooks.md" || true)"
fi

# Root entry docs
cp -f "$TEMPLATES/AGENTS.md" "$TARGET/AGENTS.md"
cp -f "$TEMPLATES/CLAUDE.md" "$TARGET/CLAUDE.md"

merge_dir "$TEMPLATES/agents" "$TARGET/agents"
if [[ "$REFRESH" -eq 1 && -n "$BAK_CONTROL" ]]; then
  restore_file "$TARGET/agents/CONTROL_PLANE.md" "$BAK_CONTROL"
fi

mkdir -p "$TARGET/specs"
for item in README.md SKILLS.md; do
  [[ -f "$TEMPLATES/specs/$item" ]] && cp -f "$TEMPLATES/specs/$item" "$TARGET/specs/$item"
done
if [[ -f "$TEMPLATES/specs/stack.md" ]]; then
  if [[ "$REFRESH" -eq 1 ]]; then
    copy_if_missing "$TEMPLATES/specs/stack.md" "$TARGET/specs/stack.md"
  else
    cp -f "$TEMPLATES/specs/stack.md" "$TARGET/specs/stack.md"
  fi
fi

if [[ -d "$TEMPLATES/specs/contract" ]]; then
  if [[ "$REFRESH" -eq 1 ]]; then
    mkdir -p "$TARGET/specs/contract"
    if [[ -f "$TEMPLATES/specs/contract/README.md" ]]; then
      copy_if_missing "$TEMPLATES/specs/contract/README.md" "$TARGET/specs/contract/README.md"
    fi
    for f in "$TEMPLATES/specs/contract"/*; do
      [[ -f "$f" ]] || continue
      base="$(basename "$f")"
      [[ "$base" == "README.md" ]] && continue
      cp -f "$f" "$TARGET/specs/contract/$base"
    done
  else
    merge_dir "$TEMPLATES/specs/contract" "$TARGET/specs/contract"
  fi
fi

merge_dir "$TEMPLATES/specs/_templates" "$TARGET/specs/_templates"

mkdir -p "$TARGET/specs/features/_bootstrap"
DATE="$(date +%Y-%m-%d)"
BOOTSTRAP="$TARGET/specs/features/_bootstrap/README.md"
if [[ "$REFRESH" -eq 1 && -f "$BOOTSTRAP" ]]; then
  {
    echo
    echo "## Refreshed $DATE"
    echo
    echo "Refreshed by Kephale AI Toolkit scripts/install.sh --refresh"
    echo
    echo "Source: $KPL_REPO_URL @ $KPL_REF"
  } >>"$BOOTSTRAP"
else
  {
    echo "# Bootstrap"
    echo
    echo "Installed by Kephale AI Toolkit scripts/install.sh on $DATE"
    echo
    echo "Source: $KPL_REPO_URL @ $KPL_REF"
  } >"$BOOTSTRAP"
fi

if [[ -d "$TEMPLATES/memory" ]]; then
  if [[ "$REFRESH" -eq 1 ]]; then
    merge_memory_refresh "$TEMPLATES/memory" "$TARGET/memory"
  else
    merge_dir "$TEMPLATES/memory" "$TARGET/memory"
  fi
fi

if [[ "$REFRESH" -eq 1 ]]; then
  merge_cursor_refresh "$TEMPLATES/tool-stubs/cursor" "$TARGET/.cursor"
  merge_claude_refresh "$TEMPLATES/tool-stubs/claude" "$TARGET/.claude"
else
  merge_dir "$TEMPLATES/tool-stubs/cursor" "$TARGET/.cursor"
  merge_dir "$TEMPLATES/tool-stubs/claude" "$TARGET/.claude"
fi

mkdir -p "$TARGET/.opencode"
merge_dir "$TEMPLATES/tool-stubs/opencode/skills" "$TARGET/.opencode/skills"
if [[ -d "$TEMPLATES/tool-stubs/opencode/plugins" ]]; then
  merge_dir "$TEMPLATES/tool-stubs/opencode/plugins" "$TARGET/.opencode/plugins"
fi
if [[ -f "$TEMPLATES/tool-stubs/opencode/opencode.json" && ! -f "$TARGET/.opencode/opencode.json" ]]; then
  cp -f "$TEMPLATES/tool-stubs/opencode/opencode.json" "$TARGET/.opencode/opencode.json"
fi

if [[ "$REFRESH" -eq 1 ]]; then
  [[ -n "$BAK_HOOK_AGENTS" ]] && restore_file "$TARGET/agents/skills/architecture-mentor/stack-hooks.md" "$BAK_HOOK_AGENTS"
  [[ -n "$BAK_HOOK_CURSOR" ]] && restore_file "$TARGET/.cursor/skills/architecture-mentor/stack-hooks.md" "$BAK_HOOK_CURSOR"
  [[ -n "$BAK_HOOK_CLAUDE" ]] && restore_file "$TARGET/.claude/skills/architecture-mentor/stack-hooks.md" "$BAK_HOOK_CLAUDE"
  [[ -n "$BAK_HOOK_OPENCODE" ]] && restore_file "$TARGET/.opencode/skills/architecture-mentor/stack-hooks.md" "$BAK_HOOK_OPENCODE"
fi

if [[ -f "$KIT_ROOT/scripts/merge-kpl-io-hooks.sh" ]]; then
  bash "$KIT_ROOT/scripts/merge-kpl-io-hooks.sh" "$TARGET"
fi

if [[ -d "$KIT_ROOT/practices" ]]; then
  merge_dir "$KIT_ROOT/practices" "$TARGET/agents/practices"
fi

if [[ -n "$CLEANUP" ]]; then
  rm -rf "$CLEANUP"
fi

echo
echo "Done. Control plane ${MODE}ed at:"
echo "  $TARGET"
echo
if [[ "$REFRESH" -eq 1 ]]; then
  echo "Preserved: specs/features/**, stack.md, contract/README.md, CONTROL_PLANE,"
  echo "  stack-hooks.md, memory INDEX/cards, opencode.json; hooks merged."
  echo "Updated: AGENTS/CLAUDE, agents skills/rules/hooks, tool skill packs, token-io."
else
  echo "Next:"
  echo "  1. Open this project in Cursor / Claude Code / OpenCode"
  echo "  2. Fill specs/stack.md for your stack"
  echo "  3. Start with skill: feature-discovery"
fi
echo
echo "Did not modify application source (src/, app/, etc.)."
