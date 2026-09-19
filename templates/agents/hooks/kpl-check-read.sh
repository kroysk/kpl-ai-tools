#!/usr/bin/env sh
# KPL token-I/O gate. Fail-open: any unexpected error allows the tool call.
allow() {
  printf '%s\n' '{"permission":"allow"}'
  exit 0
}

deny() {
  msg="$1"
  # Keep JSON single-line. Escape is minimal; message is kit-controlled.
  printf '%s\n' "{\"permission\":\"deny\",\"decision\":\"block\",\"reason\":\"${msg}\",\"agent_message\":\"${msg}\",\"user_message\":\"${msg}\"}"
  exit 2
}

trap 'allow' INT TERM

if [ "${KPL_READ_MIN_LINES-}" = "0" ]; then
  allow
fi

raw=$(cat || true)
if [ -z "$raw" ]; then
  allow
fi

root=""
walk="$PWD"
i=0
while [ "$i" -lt 8 ] && [ -n "$walk" ]; do
  if [ -f "$walk/agents/io-policy.json" ] || [ -f "$walk/AGENTS.md" ]; then
    root="$walk"
    break
  fi
  parent=$(dirname "$walk")
  [ "$parent" = "$walk" ] && break
  walk="$parent"
  i=$((i + 1))
done

if [ -z "$root" ] && [ -n "${0-}" ]; then
  here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
  cand=$(dirname "$here")
  cand2=$(dirname "$cand")
  for walk in "$cand" "$cand2"; do
    if [ -f "$walk/agents/io-policy.json" ] || [ -f "$walk/AGENTS.md" ]; then
      root="$walk"
      break
    fi
  done
fi

min=500
msg="File exceeds the KPL read threshold (default 500 lines). Load skill bulk-read. Use Grep or Read with offset/limit."
if [ -n "$root" ] && [ -f "$root/agents/io-policy.json" ]; then
  pol="$root/agents/io-policy.json"
  if command -v python3 >/dev/null 2>&1; then
    extracted=$(python3 -c 'import json,sys
p=json.load(open(sys.argv[1],encoding="utf-8"))
print(p.get("minLines",500))
print(p.get("denyMessage",""))' "$pol" 2>/dev/null) || extracted=""
    if [ -n "$extracted" ]; then
      min=$(printf '%s\n' "$extracted" | sed -n '1p')
      dmsg=$(printf '%s\n' "$extracted" | sed -n '2p')
      [ -n "$dmsg" ] && msg="$dmsg"
    fi
  fi
fi
if [ -n "${KPL_READ_MIN_LINES-}" ]; then
  min="$KPL_READ_MIN_LINES"
fi
case "$min" in
  ''|*[!0-9]*) min=500 ;;
esac
if [ "$min" -le 0 ]; then
  allow
fi

# Targeted Read (offset/limit present and not null)
if printf '%s' "$raw" | grep -Eq '"offset"|"limit"'; then
  if ! printf '%s' "$raw" | grep -Eq '"offset"[[:space:]]*:[[:space:]]*null|"limit"[[:space:]]*:[[:space:]]*null'; then
    # If either field has a numeric value, allow. Crude but fail-open on doubt happens below.
    if printf '%s' "$raw" | grep -Eq '"(offset|limit)"[[:space:]]*:[[:space:]]*[0-9]+'; then
      allow
    fi
  fi
fi

file=$(printf '%s' "$raw" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p; t; s/.*"filePath"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p; t; s/.*"path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
command=$(printf '%s' "$raw" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)

count_lines() {
  f="$1"
  [ -f "$f" ] || return 1
  wc -l < "$f" | tr -d ' '
}

resolve_file() {
  rel="$1"
  [ -z "$rel" ] && return 1
  if [ -f "$rel" ]; then
    printf '%s\n' "$rel"
    return 0
  fi
  if [ -n "$root" ] && [ -f "$root/$rel" ]; then
    printf '%s\n' "$root/$rel"
    return 0
  fi
  return 1
}

if [ -n "$file" ]; then
  resolved=$(resolve_file "$file") || allow
  lines=$(count_lines "$resolved") || allow
  if [ "$lines" -ge "$min" ]; then
    deny "$msg"
  fi
  allow
fi

if [ -n "$command" ]; then
  if printf '%s' "$command" | grep -Eqi '\|[[:space:]]*(grep|rg|findstr|awk|sed)\b'; then
    allow
  fi
  if printf '%s' "$command" | grep -Eqi '(^|[[:space:];&]|&&|\|)[[:space:]]*(cat|head|tail|less|more)[[:space:]]'; then
    # last path-like token
    bfile=$(printf '%s' "$command" | tr '\t' ' ' | sed 's/.* //' | tr -d "'\"")
    resolved=$(resolve_file "$bfile") || allow
    lines=$(count_lines "$resolved") || allow
    if [ "$lines" -ge "$min" ]; then
      deny "$msg"
    fi
  fi
fi

allow
